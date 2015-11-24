module HistoricalParameter
  module ViewHelpers
    extend ActiveSupport::Concern

    included do
    end

    def historical_form_for(*args, &block)
      options = args.extract_options!
      options[:builder] = options[:builder].constantize unless options[:builder].blank?
      options[:builder] ||= HistoricalFormBuilder
      output = form_for(*args << options, &block)
      if @after_historical_form_callbacks
        fields = @after_historical_form_callbacks.each do |callback|
          output << callback.call
        end
      end
      output
    end

    def after_historical_form(&block)
      @after_historical_form_callbacks ||= []
      @after_historical_form_callbacks << block
    end
  end
end
