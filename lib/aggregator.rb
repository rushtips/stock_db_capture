module Aggregator

  BEGIN_TIME = 9.hours + 30.minutes
  END_TIME = 16.hours
  UTC_OFFSET = 8.hours

  def compute_aggregate(tid, date, period_in_seconds)
    start_time = date.to_time + BEGIN_TIME
    end_time = start_time + period_in_seconds
    exit_time = date.to_time + END_TIME
    while (end_time <= exit_time) do
      recs = find(:all, :conditions => form_where_clause(tid, start_time, end_time), :order => 'last_trade_time')

      generate_aggregate(tid, date, start_time, period_in_seconds, recs) unless recs.empty?

      start_time += period_in_seconds
      end_time = start_time + period_in_seconds
    end
  end

  def form_where_clause(tid, btime, etime)
    "ticker_id = #{tid} AND last_trade_time >= '#{btime.to_s(:db)}' AND last_trade_time <= '#{etime.to_s(:db)}'"
  end

  def generate_aggregate(tid, date, start_time, period, recs)
    tid = recs.first.ticker_id
    open = recs.first.last_trade
    close = recs.last.last_trade
    high = recs.inject(0.0) { |max, rec| rec.last_trade > max ? rec.last_trade : max }
    low = recs.inject(high) { |min, rec| rec.last_trade < min ? rec.last_trade : min }
    vol = recs.inject(0) { |sum, rec| sum + rec.volume } / recs.length

    Aggregate.create!(:ticker_id => tid, :date => date, :start => start_time-UTC_OFFSET, :open => open,
                      :close => close, :high => high, :low => low, :volume => vol, :period => period)
  end
end