# Copyright © Kevin P. Nolan 2009 All Rights Reserved.

require 'rubygems'
#require 'watch_list'

namespace :active_trader do
  namespace :watch_list do

    desc "Load New Symbols for the Watch List"
    task :populate => :environment do
      log_name = "stock_watch_#{Date.today.to_s(:db)}.log"
      @logger ||= ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, 'log', log_name))
      @sw = Trading::StockWatcher.new(@logger)
      @sw.reset()
    end

    desc "Begin Updating Watch List"
    task :start_watching => :environment do
      log_name = "stock_watch_#{Date.today.to_s(:db)}.log"
      @logger ||= ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, 'log', log_name))
      @sw = Trading::StockWatcher.new(@logger)
      @sw.start_watching()
    end
  end
end