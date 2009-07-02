require 'yaml'
require 'ostruct'

module Analytics

  class Hash
    # Replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
    #
    # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
    def to_yaml( opts = {} )
      YAML::quick_emit( object_id, opts ) do |out|
        out.map( taguri, to_yaml_style ) do |map|
          sort.each do |k, v|   # <-- here's my addition (the 'sort')
            map.add( k, v )
          end
        end
      end
    end
  end

  class BuilderException < Exception
    def initialize(name)
      super("Problem with statement named: #{name}")
    end
  end

  class Builder

    def initialize(options)
      @options = options
      @openings = []
      @closings = []
      @openings = []
      @stop_loss = nil
      @descriptions = []
    end

    def find_stop_loss(); @stop_loss; end

    def find_opening(name)
      @openings.find { |o| o.name == name }
    end

    def find_closing(name)
      @closings.find { |c| c.name == name }
    end

    def has_pair?(name)
      find_opening(name) && find_closing(name)
    end

    def open_position(name, params={}, &block)
      raise ArgumentError.new("Block missing for open position #{name}") unless block_given?
      Strategy.record_open!(name, @descriptions.shift, params.to_yaml)
      opening = OpenStruct.new
      opening.name = name
      opening.params = params
      opening.block = block
      @openings << opening
    end

    def stop_loss(threshold, options={})
      raise ArgumentError, "Threshdold must a percentage between between 0 and 100" unless (0.0..100.0).include? threshold.to_f
      sloss = OpenStruct.new
      sloss.threshold = threshold.to_f
      sloss.options = options
      @stop_loss = sloss
    end

    def close_position(name, params={}, &block)
      raise ArgumentError.new("Block missing for close position #{name}") unless block_given?
      Strategy.record_close!(name, @descriptions.shift, params.to_yaml)
      closing = OpenStruct.new
      closing.name = name
      closing.params = params
      closing.block = block
      @closings << closing
    end

    def desc(string)
      @descriptions << string
    end
  end
end
