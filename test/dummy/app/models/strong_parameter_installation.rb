class StrongParameterInstallation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  acts_as_historical_parameter :area, 1
end
