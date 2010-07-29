require 'rubygems'
require 'daemons'
require 'beanstalk-client'
require 'thread_pool'
require 'rpctypes'
require 'remote_logger'
require 'monitor'
require 'task/message'
require 'task/config/compile/dsl'
require 'task/config/compile/exceptions'
#
# Somec monkey patching on the Hash class that is too specialized to really go into here
#
class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end

  def to_mod
    hash = self
    Module.new do
      hash.each_pair do |key, value|
        define_method key do
          value
        end
      end
    end
  end
end


#--------------------------------------------------------------------------------------------------------------------
# A Task::Base is represents a container within which a number of tasks are started each on it's own thread . The Base
# container is generally a daemon although it can be configured to uun on top of the shell.
# Tasks usuall are both consumers and producers. The model of a task is
# that is runs on it's own thread and waits for messages directed it before acting upon it. A task has a Proc associated
# with it which get's executed once the input payload sent with the message has been decoded. It the task fires the Proc,
# passing in the decoded payload args. In the usual case the Proc returns set of values when are then encoded into the
# message to be delivered to all of its target tasks (which may be more than one in a fannot) or more likely just the
# following task. All of the payload transscoding is done automatically and may generate error of the wrong types or no.
# of args is returned. It is possible for a task to execute a loop in wich mutiple messages are sprayed out before the
# thread goes back to waiting.
#--------------------------------------------------------------------------------------------------------------------
module Task
  class Base
    POOL_SIZE = 5
    DEFAULT_PORT = 11300
    DEFAULT_ADDR = '127.0.0.1'
    THREAD_POOL_SIZE = 20

    include Task::Config::Compile
    include Beanstalk

    delegate :info, :error, :debug, :to => :logger

    attr_reader :options, :post_process
    attr_reader :config_basename, :config
    attr_reader :con_pool, :delivery_q, :ip_addrs, :thpool
    attr_reader :logger
    attr_accessor :proc_id, :deferred_jobs, :completed_defers, :prev_counts

    #--------------------------------------------------------------------------------------------------------------------
    # The constructor for a daemon class. Since the worker daemons are forked, they get a copy of the process start which
    # of course includes the state stored here. The serve() method actually invokes a separate process.
    #--------------------------------------------------------------------------------------------------------------------
    def initialize(config_file, proc_id)
      @config_basename = File.basename(config_file)
      @config = Dsl.load(config_file)
      @proc_id = proc_id
      @thpool = ThreadPool.new(THREAD_POOL_SIZE)
      @deferred_jobs = 0
      @completed_defers = 0
      @uthreads = []
      @delivery_q = ::Queue
      @ip_addrs = generate_socket_addrs()
      @con_pool = Beanstalk::Pool.new(ip_addrs)
      @options = config.options.reverse_merge :verbose => false, :logger_type => :remote, :message_timeout => 30
      #create readers for each of the above options
      self.extend self.options.to_mod

      Message.bind_queue(delivery_q)
      Message.bind_config(config)
      Message.default_timeout = options[:message_timeout]
      Message.push_task = true

      @logger = initialize_logger()

      Message.attach_logger(logger)
      Timeseries.attach_logger(logger)
      Thread.abort_on_exception = false
    end
    #
    # Set up an appropriate logger destination. If verbose is true we just log to $stderr, otherwise we log to a file
    # containing the proc_id (0..number of procs). Finally if were running as a daemon we bind to the Drb Service
    # that all daeomons write to.
    #
    def initialize_logger()
      case logger_type
      when :local
        log_path = File.join(RAILS_ROOT, 'log', "#{config_basename}.log")
        system("cat /dev/null > #{log_path}")
        ActiveSupport::BufferedLogger.new(log_path)
      when :remote
        RemoteLogger.new(config_basename, File.join(RAILS_ROOT, 'log'), proc_id)
      when :stderr
        logger = ActiveSupport::BufferedLogger.new($stderr)
        logger.auto_flushing = true
        logger
      else
        raise ArgumentError, "logger_type must be :local,:remote or :stderr"
      end
    end

    def adjust_deferred_jobs(amt)
      #jstats_mutex.synchronize { @deferred_jobs + amt }
      0
    end

    #
    # This method and block allow us to abstract the semantics of message publication such that protocol client details
    # are kept out of the Message class
    #
    def publish(task, contents)
      con_pool.put(contents, :ttr => 60)
    end
    publisher = lambda(task, contents) { publish(task, contents) }

    #--------------------------------------------------------------------------------------------------------------------
    # The serve function is called as the entry point for any number of worker tasks, each responding to messages and
    # sending out messages along with the results of the given task. Retrun values from one task become the input args
    # of one or more target tasks. Any type conversion need to map output args to input args is done automatically.
    # Since Ruby objects are stored on the heap but the messages and payloads are stored in a NUMA, proxy classes are
    # often generated to inplement a pass-by-reference protocol. Upon reciept of payloads with Proxy objects they are
    # automatically derefernced into a Heap local object.
    #--------------------------------------------------------------------------------------------------------------------
    def serve(*use_tasks)
      begin
        startt = global_startt = Time.now
        #
        # Create a list of tasks taken from the topoligically sorted chain of tasks, start with the initial task
        # and ending with the terminal task
        #
        if use_tasks.empty?
          tasks = config.tsort.map { |name| config.lookup_task(name) }
        else
          tasks = config.tsort.map { |name| use_tasks.include?(name) ? config.lookup_task(name) : nil }
          tasks.compact!
        end

        info "Number of tasks: #{tasks.length}"

#        tcount = 0
#        EM.add_periodic_timer(10) do
#          pqlen = delivery_q.instance_variable_get(:@popq).length
#          iqlen = delivery_q.size
#          iqlen = delivery_q.length
#          $stderr.puts("[#{proc_id}:#{tcount +=1}:#{iqlen}] Defers: #{adjust_deferred_jobs(0)}:#{completed_defers}\t Msg: #{Message.sent_messages}:#{Message.received_messages}")
#          $stderr.puts("[#{proc_id}:#{tcount +=1}:#{pqlen}:#{iqlen}] Defers: #{adjust_deferred_jobs(0)}:#{completed_defers}\t Msg: #{Message.sent_messages}:#{Message.received_messages}")

#          if no_activity?(Message.sent_messages, Message.received_messages, completed_defers)
#            puts "No message activity...initiating stop"
#            finish(startt)
#          end
#        end

        producers = tasks.select { |task| task.parent.nil? && proc_id.zero? }
        consumers = tasks.select { |task| task.parent }
        #
        # Now run the producers
        #
        producers.each do |task|
          logger.debug "Producer #{task.name} invoked" if verbose
          task.eval_body([])
        end
        #
        # Job processing
        #
        loop do
          begin
            thpool.run_defered_callbacks()
            job = con_pool.reserve(10)
            puts "recieved jobid: #{job.id}"
            job.delete
          rescue Beanstalk::Timeout => e
            $stderr.puts "timed out waiting for jobs"
            $stderr.puts e.inspect
            break
          rescue Beanstalk::UnexpectedResponse => e
            $stderr.puts e.inspect
            raise
          rescue Exception => e
            $stderr.puts e.inspect
            raise
          end
          msg = Message.receive(nil, job.body)
          task = msg.task
          completer = lambda(results) do
            adjust_deferred_jobs(-1)
            unless task.targets.empty? || task.result_protocol == :yield
              outgoing_msg = Message.new(task, results)
              outgoing_msg.deliver(&publisher)
            end
          end
          thpool.defer(nil, completer) do
            adjust_deferred_jobs(1)
            args = msg.task_args
            begin
              task.eval_body(args) #returns results
            rescue => e
              $stderr.puts "#{e.class}: #{e.message}"
              $stderr.puts(e.backtrace.join("\n"))
              raise
            end
          end
        end

        #EM.add_periodic_timer(0.100) do
        #  delivery_q.shift.deliver(exchange) unless delivery_q.empty?
        #end

        #
        # Now deliver the messages in the delivery queue, i.e. ones that were yelded
        #
#        postman = proc { |pair|
        postman = proc { |msg|
#          task, value = pair
#          msg  = value.is_a?(Array) ? Message.new(task, value) : Message.new(task, [value])
          msg.deliver(&publisher)
          delivery_q.pop(&postman)
        }
        delivery_q.pop(&postman)

      rescue => e
        $stderr.puts "#{e.class}: #{e.message}"
        $stderr.puts(e.backtrace.join("\n"))
        raise
      end
      #
      # Wait until all the threads timeout with either means that there is nothing left to do or some unrecoverable
      # error was encounted
      #
      def no_activity?(*counts)
        self.prev_counts ||= Array.new(counts.length)
        @repeats ||= 0
        status = adjust_deferred_jobs(0).zero? && (prev_counts == counts ? true : (self.prev_counts = counts and false))
        @repeats += 1 if status
        @repeats == 3
      end

      def generaate_socket_addrs(ipaddr=DEFAUL_ADDR, port=DEFAULT_PORT, count=POOL_SIZE)
        addr_ary = []
        count.times { addr_ary << "#{ipaddr}:#{port}" }
        addr_ary
      end

      def finish(startt)
        endt = Time.now
        delta = endt - startt
        info "#{options[:app_name]} total elapsed time #{Base.format_et(delta)}"
        con_pool.status.each_pair { |k,v| puts "#{k}:\t#{v}"}
      end
    end

    def Base.run(config_path, server_count)
      Base.env_check()
      #
      # TODO we might want to go through the hassle of creating ApplicationOjbects and ApplicationsGroups (which have one 7monitor)
      #
      child_count = server_count - 1
      child_count.times do |child_index|
        Process.fork do
          ActiveRecord::Base.connection.reconnect!
          Base.exec(config_path, child_index)
        end
      end
      if child_count > 0
        p Process.waitall
      else
        Signal.trap('INT') { con_pool.close; exit }
        Signal.trap('TERM'){ con_pool.close; exit }
        Base.exec(config_path, 0)
      end
    end

    def Base.exec(config_path, child_index)
      server = Base.new(config_path, child_index)
      server.serve()
      #      server.serve(:rsi_rvi_50)
      #      server.serve(:scan_gen,:timeseries_args, :rsi_trigger_14)
      #        server.serve(i, [:scan_gen])
      #        server.serve(i, [:timeseries_args])
      #        server.serve(i, [:rsi_trigger_14])
      #        server.serve(i, [:rsi_rvi_50])
      #        server.serve(:lagged_rsi_difference)
      #        end
      #     end
      summary_str = ResultAnalysis.memoized_thresholds
      server.info summary_str
    end
    #--------------------------------------------------------------------------------------------------------------------
    #  Verifies that the preconditions to a successful run are met, print an error msg and exit with a bad status if not
    #--------------------------------------------------------------------------------------------------------------------
    def Base.env_check
      unless Position.count.zero?
        $stderr.puts "Position table is not empty! (needs to be truncated first)"
        exit(5)
      end
    end
    #--------------------------------------------------------------------------------------------------------------------
    # format elasped time values. Does some pretty printing about delegating part of the base unit (seconds) into minutes.
    # Future revs where we backtest an entire decade we will, no doubt include hours as part of the time base
    #--------------------------------------------------------------------------------------------------------------------
    def Base.format_et(seconds)
      if seconds > 60.0 and seconds < 120.0
        format('%d minute and %d seconds', (seconds/60).floor, seconds.to_i % 60)
      elsif seconds > 120.0
        format('%d minutes and %d seconds', (seconds/60).floor, seconds.to_i % 60)
      else
        format('%2.2f seconds', seconds)
      end
    end
  end
end
