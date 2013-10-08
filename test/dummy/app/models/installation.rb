class Installation < ActiveRecord::Base
  acts_as_historical_parameter :area, 1
  attr_accessible :name
end
