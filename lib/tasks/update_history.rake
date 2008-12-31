require 'rubygems'
require 'populate_db'
require 'load_daily_close'
require 'log_returns'

extend LoadDailyClose
extend LogReturns

namespace :active_trader do

  desc "Setup the environment for live quote capture"
  task :setup => :environment do
    @logger = ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, 'log', 'update_history.log'))
  end

  desc "Update Daily Close table with new history"
  task :update_history => :setup do
    update_history()
  end

  desc "Compute returns on daily closes be scanning each row and computing closing price delta"
  task :compute_returns do
    update_returns()
  end
end