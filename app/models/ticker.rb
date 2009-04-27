# == Schema Information
# Schema version: 20090425175412
#
# Table name: tickers
#
#  id              :integer(4)      not null, primary key
#  symbol          :string(8)
#  exchange_id     :string(255)
#  active          :boolean(1)
#  dormant         :boolean(1)
#  last_trade_time :datetime
#  missed_minutes  :integer(4)      default(0)
#  validated       :boolean(1)
#  name            :string(255)
#  locked          :boolean(1)
#

class Ticker < ActiveRecord::Base
  belongs_to :exchange

  has_one  :current_listing, :dependent => :destroy
  has_many :live_quotes
  has_many :daily_closes, :dependent => :destroy
  has_many :aggregate, :dependent => :destroy
  has_many :positions, :dependent => :destroy
  has_and_belongs_to_many :scans

  def last_close
    DailyClose.connection.select_value("select adj_close from daily_closes where ticker_id = #{id} having max(date)").to_f
  end

  def listing
    current_listing
  end

  def self.lookup(symbol)
    find(:first, :conditions => { :symbol => symbol.to_s.upcase })
  end

  def self.listing_name(symbol)
    (ticker = find_by_symbol(symbol.to_s.upcase)) && ticker.name
  end

  def self.symbols
    self.connection.select_values('SELECT symbol FROM tickers ORDER BY symbol')
  end

  def self.active_symbols
    self.connection.select_values('SELECT symbol FROM tickers WHERE active = 1 ORDER BY symbol')
  end

  def self.active_ids
    self.connection.select_values('SELECT id FROM tickers WHERE active = 1 ORDER BY symbol')
  end

  def self.ids
    self.connection.select_values('SELECT symbol FROM tickers order by id').collect!(&:to_i)
  end

  def self.id_groups(count)
    ids = Ticker.connection.select_values('select id from tickers order by id').collect!(&:to_i)
    ids.in_groups_of(ids.length/count)
  end

  def self.lname(symbol)
    t = find_by_symbol(symbol.to_s.upcase)
    t.current_listing.name.split(' ').collect(&:capitalize).join(' ') if t && t.current_listing
  end
end
