# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090403161440) do

  create_table "aggregates", :force => true do |t|
    t.integer  "ticker_id"
    t.date     "date"
    t.datetime "start"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.float    "r"
    t.float    "logr"
  end

  add_index "aggregates", ["ticker_id", "date"], :name => "index_aggregates_on_ticker_id_and_date"

  create_table "aggregates_save", :force => true do |t|
    t.integer  "ticker_id"
    t.date     "date"
    t.datetime "start"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.integer  "period"
    t.float    "r"
    t.float    "logr"
    t.integer  "sample_count"
  end

  create_table "bar_10s", :force => true do |t|
    t.integer  "ticker_id"
    t.date     "date"
    t.datetime "start"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.float    "r"
    t.float    "logr"
  end

  add_index "bar_10s", ["ticker_id", "date"], :name => "index_aggregates_on_ticker_id_and_date"

  create_table "bar_30s", :force => true do |t|
    t.integer  "ticker_id"
    t.date     "date"
    t.datetime "start"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.float    "r"
    t.float    "logr"
  end

  add_index "bar_30s", ["ticker_id", "date"], :name => "index_aggregates_on_ticker_id_and_date"

  create_table "bar_5s", :force => true do |t|
    t.integer  "ticker_id"
    t.date     "date"
    t.datetime "start"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.float    "r"
    t.float    "logr"
  end

  add_index "bar_5s", ["ticker_id", "date"], :name => "index_aggregates_on_ticker_id_and_date"

  create_table "bar_60s", :force => true do |t|
    t.integer  "ticker_id"
    t.date     "date"
    t.datetime "start"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.float    "r"
    t.float    "logr"
  end

  add_index "bar_60s", ["ticker_id", "date"], :name => "index_aggregates_on_ticker_id_and_date"

  create_table "contract_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "current_listings", :force => true do |t|
    t.float   "moving_ave_50_days_change_percent_from"
    t.float   "weeks52_change_from_low"
    t.float   "weeks52_change_percent_from_low"
    t.float   "weeks52_range_low"
    t.float   "weeks52_range_high"
    t.float   "peg_ratio"
    t.float   "dividend_yield"
    t.float   "price_per_eps_estimate_current_year"
    t.float   "oneyear_target_price"
    t.float   "dividend_per_share"
    t.float   "short_ratio"
    t.float   "price_persales"
    t.float   "price_per_eps_estimate_next_year"
    t.float   "eps"
    t.float   "moving_ave_50_days"
    t.float   "price_perbook"
    t.date    "ex_dividend_date"
    t.float   "moving_ave_200_days"
    t.float   "book_value"
    t.float   "eps_estimate_current_year"
    t.float   "market_cap"
    t.float   "pe_ratio"
    t.float   "moving_ave_200_days_change_from"
    t.float   "eps_estimate_next_year"
    t.integer "ticker_id"
    t.float   "moving_ave_200_days_change_percent_from"
    t.float   "eps_estimate_next_quarter"
    t.date    "dividend_paydate"
    t.float   "weeks52_change_from_high"
    t.float   "moving_ave_50_days_change_from"
    t.float   "ebitda"
    t.float   "weeks52_change_percent_from_high"
  end

  create_table "daily_closes", :force => true do |t|
    t.integer "ticker_id", :null => false
    t.date    "date"
    t.float   "open"
    t.float   "close"
    t.float   "high"
    t.float   "low"
    t.float   "adj_close"
    t.integer "volume"
    t.integer "week"
    t.integer "month"
    t.float   "r"
    t.float   "logr"
    t.float   "alr"
  end

  add_index "daily_closes", ["ticker_id", "date"], :name => "index_daily_closes_on_ticker_id_and_date", :unique => true

  create_table "derived_value_types", :force => true do |t|
    t.string "name"
  end

  create_table "derived_values", :force => true do |t|
    t.integer  "ticker_id"
    t.integer  "derived_value_type_id"
    t.date     "date"
    t.datetime "time"
    t.float    "value"
  end

  add_index "derived_values", ["ticker_id"], :name => "ticker_id"
  add_index "derived_values", ["derived_value_type_id"], :name => "derived_value_type_id"

  create_table "exchanges", :force => true do |t|
    t.string "symbol"
    t.string "name"
    t.string "country"
    t.string "currency"
    t.string "timezone"
  end

  create_table "fast_live_quotes", :id => false, :force => true do |t|
    t.integer  "ticker_id"
    t.datetime "last_trade_time"
    t.float    "last_trade"
    t.integer  "volume"
  end

  add_index "fast_live_quotes", ["ticker_id", "last_trade_time"], :name => "index_ticker_id_last_trade_time", :unique => true

  create_table "historical_attributes", :force => true do |t|
    t.string "name"
  end

  create_table "listing_categories", :force => true do |t|
    t.string "name"
  end

  create_table "live_quotes", :id => false, :force => true do |t|
    t.integer  "ticker_id"
    t.datetime "last_trade_time"
    t.float    "last_trade"
    t.integer  "volume"
  end

  create_table "memberships", :force => true do |t|
    t.integer "ticker_id"
    t.integer "listing_category_id"
  end

  create_table "pimary_key_ids", :force => true do |t|
    t.string  "table_name"
    t.integer "auto_increment"
  end

  create_table "plot_attributes", :force => true do |t|
    t.string   "name"
    t.integer  "ticker_id"
    t.string   "type"
    t.datetime "anchor_date"
    t.integer  "period"
    t.string   "attributes"
  end

  add_index "plot_attributes", ["ticker_id"], :name => "ticker_id"

  create_table "plot_types", :force => true do |t|
    t.string  "name"
    t.string  "source_model"
    t.string  "method"
    t.string  "time_class"
    t.string  "resolution"
    t.string  "inputs"
    t.integer "num_outputs"
  end

  create_table "portfolios", :force => true do |t|
    t.string   "name"
    t.float    "initial_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "positions", :force => true do |t|
    t.integer  "ticker_id"
    t.boolean  "open"
    t.datetime "entry_date"
    t.datetime "exit_date"
    t.float    "entry_price"
    t.float    "exit_price"
    t.integer  "num_shares"
    t.string   "stop_loss"
    t.integer  "strategy_id"
    t.integer  "days_held"
    t.float    "nomalized_return"
    t.float    "risk_factor"
    t.integer  "week"
    t.integer  "population_id"
    t.integer  "ticker_population_id"
  end

  add_index "positions", ["strategy_id"], :name => "strategy_id"
  add_index "positions", ["ticker_id"], :name => "index_positions_on_portfolio_id_and_ticker_id"
  add_index "positions", ["ticker_population_id"], :name => "ticker_population_id"

  create_table "positions_scans", :id => false, :force => true do |t|
    t.integer "position_id"
    t.integer "scan_id"
  end

  add_index "positions_scans", ["position_id"], :name => "position_id"
  add_index "positions_scans", ["scan_id"], :name => "scan_id"

  create_table "scans", :force => true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
    t.text   "conditions"
    t.string "description"
  end

  create_table "scans_tickers", :id => false, :force => true do |t|
    t.integer "ticker_id"
    t.integer "scan_id"
  end

  add_index "scans_tickers", ["ticker_id"], :name => "ticker_id"
  add_index "scans_tickers", ["scan_id"], :name => "scan_id"

  create_table "shorts", :force => true do |t|
    t.string  "symbol", :limit => 8
    t.integer "count",  :limit => 8, :default => 0, :null => false
  end

  create_table "stat_values", :force => true do |t|
    t.integer  "historical_attribute_id"
    t.integer  "ticker_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "sample_count"
    t.float    "mean"
    t.float    "min"
    t.float    "max"
    t.float    "stddev"
    t.float    "absdev"
    t.float    "skew"
    t.float    "kurtosis"
    t.float    "slope"
    t.float    "yinter"
    t.float    "cov00"
    t.float    "cov01"
    t.float    "cov11"
    t.float    "chisq"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cv"
  end

  create_table "strategies", :force => true do |t|
    t.string "name"
    t.string "description"
    t.string "params_yaml"
  end

  add_index "strategies", ["name"], :name => "index_strategies_on_name", :unique => true

  create_table "tickers", :force => true do |t|
    t.string   "symbol",          :limit => 8
    t.string   "exchange_id"
    t.boolean  "active"
    t.boolean  "dormant",                      :default => false
    t.datetime "last_trade_time"
    t.integer  "missed_minutes",               :default => 0
    t.boolean  "validated"
    t.string   "name"
    t.boolean  "locked"
  end

  add_index "tickers", ["symbol"], :name => "index_tickers_on_symbol", :unique => true
  add_index "tickers", ["id", "last_trade_time"], :name => "index_tickers_on_id_and_last_trade_time"

  create_table "var_aggregates", :force => true do |t|
    t.integer  "ticker_id"
    t.date     "date"
    t.datetime "start"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.integer  "period"
    t.float    "r"
    t.float    "logr"
    t.integer  "sample_count"
  end

  add_index "var_aggregates", ["ticker_id", "start", "period"], :name => "index_aggregates_on_ticker_id_and_start_and_period", :unique => true
  add_index "var_aggregates", ["ticker_id", "date"], :name => "index_aggregates_on_ticker_id_and_date"

  add_foreign_key "daily_closes", ["ticker_id"], "tickers", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "daily_closes_fk_ticker_id_tickers_id"

  add_foreign_key "derived_values", ["ticker_id"], "tickers", ["id"], :name => "derived_values_ibfk_1"
  add_foreign_key "derived_values", ["derived_value_type_id"], "derived_value_types", ["id"], :name => "derived_values_ibfk_2"

  add_foreign_key "plot_attributes", ["ticker_id"], "tickers", ["id"], :name => "plot_attributes_ibfk_1"

  add_foreign_key "positions", ["ticker_population_id"], "scans", ["id"], :name => "positions_ibfk_4"
  add_foreign_key "positions", ["ticker_id"], "tickers", ["id"], :name => "positions_ibfk_2"
  add_foreign_key "positions", ["strategy_id"], "strategies", ["id"], :name => "positions_ibfk_3"

  add_foreign_key "positions_scans", ["position_id"], "positions", ["id"], :name => "positions_scans_ibfk_1"
  add_foreign_key "positions_scans", ["scan_id"], "scans", ["id"], :name => "positions_scans_ibfk_2"

  add_foreign_key "scans_tickers", ["ticker_id"], "tickers", ["id"], :name => "scans_tickers_ibfk_1"
  add_foreign_key "scans_tickers", ["scan_id"], "scans", ["id"], :name => "scans_tickers_ibfk_2"

end
