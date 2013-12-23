module HistoricalParameter
  module ActsAsHistoricalParameter
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def define_historical_getter(name)
        class_eval <<-EOM
          def #{name}
            @#{name} ||= #{name}_history.first :order => "valid_from DESC"
            @#{name}.value if @#{name}
          end
        EOM
      end

      def define_historical_setter(name)
        class_eval <<-EOM
          def set_#{name}(value, from)
            if value
              @#{name} = #{name}_history.build :valid_from => from, :value => value
            end
          end
          def #{name}=(value)
            self.set_#{name}(value, Time.zone.now)
          end
        EOM
      end

      def define_historical_values(name)
        class_eval <<-EOM
          def #{name}_values
            hps = #{name}_history.all(:order => "valid_from")
            values = []
            if hps.length >= 2
              values = hps.each_cons(2).collect do |a|
                [
                  a[0].valid_from,
                  a[1].valid_from,
                  a[0].value
                ]
              end
            end
            lv = hps.last
            if lv
              values + [[lv.valid_from, nil, lv.value]]
            else
              nil
            end
          end
        EOM
      end

      def define_historical_sum(name)
        class_eval <<-EOM
          def #{name}_sum(start_time, end_time)
            #{name}_values.sum do |entry|
              if entry[1] and start_time < entry[1]
                stop = entry[1] < end_time ? entry[1] : end_time
                if start_time > entry[0]
                  yield start_time, stop, entry[2]
                else
                  yield entry[0], stop, entry[2]
                end
              elsif entry[1].nil? and end_time > entry[0]
                if start_time > entry[0]
                  yield start_time, end_time, entry[2]
                else
                  yield entry[0], end_time, entry[2]
                end
              else
                0
              end
            end
          end
        EOM
      end

      def acts_as_historical_parameter(name, ident)
        ass_sym = "#{name}_history".to_sym
        attr_sym = "#{ass_sym}_attributes".to_sym
        has_many ass_sym, :as => :parameterized, :class_name => "HistoricalParameter::HistoricalParameter", :conditions => {:ident => ident}
        accepts_nested_attributes_for ass_sym, :allow_destroy => true
        unless defined?(ActiveModel::ForbiddenAttributesProtection) and included_modules.include?(ActiveModel::ForbiddenAttributesProtection)
          attr_accessible attr_sym
        end
        define_historical_getter(name)
        define_historical_setter(name)
        define_historical_values(name)
        define_historical_sum(name)
      end
    end
  end
end

ActiveRecord::Base.send :include, HistoricalParameter::ActsAsHistoricalParameter
