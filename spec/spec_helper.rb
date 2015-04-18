require_relative '../lib/reek/spec/spec'
require_relative '../lib/reek/core/ast_node_class_map'
require_relative '../lib/reek/configuration/app_configuration'

require 'factory_girl'

begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

FactoryGirl.find_definitions

SAMPLES_DIR = 'spec/samples'

# Simple helpers for our specs.
module Helpers
  def with_test_config(config)
    if config.is_a? String
      Reek::Configuration::AppConfiguration.load_from_file(config)
    elsif config.is_a? Hash
      Reek::Configuration::AppConfiguration.class_eval do
        @configuration = config
      end
    else
      raise "Unknown config given in `with_test_config`: #{config.inspect}"
    end
    yield if block_given?
    Reek::Configuration::AppConfiguration.reset
  end

  # :reek:UncommunicativeMethodName
  def s(type, *children)
    @klass_map ||= Reek::Core::ASTNodeClassMap.new
    @klass_map.klass_for(type).new(type, children)
  end

  def ast(*args)
    s(*args)
  end
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.include FactoryGirl::Syntax::Methods
  config.include Helpers
end
