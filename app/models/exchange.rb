# == Schema Information
# Schema version: 20081228175347
#
# Table name: exchanges
#
#  id       :integer(4)      not null, primary key
#  symbol   :string(255)
#  name     :string(255)
#  country  :string(255)
#  currency :string(255)
#  timezone :string(255)
#

class Exchange < ActiveRecord::Base
end
