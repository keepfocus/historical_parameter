module HistoricalParameter
  class HistoricalParameter < ActiveRecord::Base
    belongs_to :parameterized, :polymorphic => true
    attr_accessible :valid_from, :value, :comment
  end
end
