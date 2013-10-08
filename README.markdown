HistoricalParameter
===================

System and models for working with historically changing parameters.

Installation
============

To install add the following line to your Gemfile:

    gem 'historical_parameter', :git => 'git://github.com/keepfocus/historical_parameter.git'

You will need to isert the following javascript into your application.js to use the view helpers:

    //= require acts_as_historical_parameter

To add a migration for the table used to store historical data use this rake command:

    rake historical_parameter_rails_engine:install:migrations

Example
=======

    class IceCream << ActiveRecord::Base
      # Enable a historical parameter price with id 1
      acts_as_historical_parameter :price, 1

      def get_sales_for_period(period_start, period_end)
        # Do some magic to load # of icecreams of this type
        # sold in the given period
      end

      def get_earnings_for_period(period_start, period_end)
        # Use block sumation to calculate
        price_sum do |period_start, period_end, price|
          # Multiply current price by # of icecreams sold
          get_sales_for_period(period_start, period_end) * value
        end
      end
    end

    # Load income from first ice for year to date.
    IceCream.find(1).get_earnings_for_period(Time.zone.now.beginning_of_year, Time.zone.now)

There are helpers to easilly create a form that allows editing of historical
parameters for a model. First if you need to create a form with historical
editing use the `historical_form_for` helper instead of a standard `form_for`.
This will setup the correct builder, this means a form for editing the
IceCreams from before will look like:

    <%= historical_form_for(@ice_cream) do |f| %>
      <!-- Fields for other attributes ... -->
      <%= f.historical_form_for :price %>
      <%= f.new_history_value_button :price %>
    <% end %>

Copyright (c) 2010-2013 KeepFocus A/S, released under the MIT license
