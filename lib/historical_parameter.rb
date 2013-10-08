require 'historical_parameter/acts_as_historical_parameter'
require 'historical_parameter/controller_extensions'
require 'historical_parameter/historical_form_builder'
require 'historical_parameter/view_helpers'

module HistoricalParameter
  module Rails
    class Engine < ::Rails::Engine
      initializer 'historical_parameter.view_helpers' do
        ActionView::Base.send :include, HistoricalParameter::ViewHelpers
      end
    end
  end
end
