# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'rr'
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "historical_parameter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "historical_parameter"
  s.version     = HistoricalParameter::VERSION
  s.authors     = ["Jakob Skov-Pedersen"]
  s.email       = ["jasp@keepfocus.dk"]
  s.homepage    = "http://github.com/keepfocus/historical_parameter"
  s.summary     = "System for having historically changing attributes in rails"
  s.description = "Create model attributes that can change over time where history must be preserved. Uses a separate model to handle storing the data."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.14"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rr"
end

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end
