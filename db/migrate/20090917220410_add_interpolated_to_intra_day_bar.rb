class AddInterpolatedToIntraDayBar < ActiveRecord::Migration
  def self.up
    add_column :daily_bars, :interpolated, :boolean
  end

  def self.down
    remove_column :daiy_bars, :interpolated
  end
end
