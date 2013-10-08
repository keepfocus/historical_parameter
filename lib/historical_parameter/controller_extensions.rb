module HistoricalParameter
  module ControllerExtensions
    extend ActiveSupport::Concern

    included do
    end

    def handle_add_value(object, method, attributes)
      if params[:"add_#{method}_value"]
        object.attributes = attributes
        object.send(method).build(:valid_from => Time.now)
        render :action => "edit"
      else
        false
      end
    end
  end
end

ActionController::Base.send :include, HistoricalParameter::ControllerExtensions
