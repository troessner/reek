# frozen_string_literal: true
require_relative 'spec/should_reek'
require_relative 'spec/should_reek_of'
require_relative 'spec/should_reek_only_of'

module Reek
  #
  # Provides matchers for Rspec, making it easy to check code quality.
  #
  # If you require this module somewhere within your spec (or in your spec_helper),
  # Reek will arrange to update Spec::Runner's config so that it knows about the
  # matchers defined here.
  #
  # === Examples
  #
  # Here's a spec that ensures there are no active code smells in the current project:
  #
  #  describe 'source code quality' do
  #    Dir['lib/**/*.rb'].each do |path|
  #      it "reports no smells in #{path}" do
  #        File.new(path).should_not reek
  #      end
  #    end
  #  end
  #
  # And here's an even simpler way to do the same:
  #
  #  it 'has no code smells' do
  #    Dir['lib/**/*.rb'].should_not reek
  #  end
  #
  # Here's a simple check of a code fragment:
  #
  #  'def equals(other) other.thing == self.thing end'.should_not reek
  #
  # To check for specific smells, use something like this:
  #
  #   ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'
  #   ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
  #   ruby.should reek_of(:Duplication, /@other.thing.foo/)
  #   ruby.should_not reek_of(:FeatureEnvy)
  #
  # @public
  module Spec
    #
    # Checks the target source code for instances of "smell type"
    # and returns true only if it can find one of them that matches.
    #
    # You could pass many different types of input here:
    #   - :UtilityFunction
    #   - "UtilityFunction"
    #   - Reek::Smells::UtilityFunction
    #
    # It is recommended to pass this as a symbol like :UtilityFunction. However we don't
    # enforce this.
    #
    # Additionally you can be more specific and pass in "details" you
    # want to check for as well e.g. "name" or "count" (see the examples below).
    # The parameters you can check for are depending on the smell you are checking for.
    # For instance "count" doesn't make sense everywhere whereas "name" does in most cases.
    # If you pass in a parameter that doesn't exist (e.g. you make a typo like "namme") Reek will
    # raise an ArgumentError to give you a hint that you passed something that doesn't make
    # much sense.
    #
    # @param smell_type [Symbol, String, Class] The "smell type" to check for.
    # @param details [Hash] A hash containing "smell warning" parameters
    # @param configuration [Reek::Configuration::AppConfiguration] The configuration that should be used.
    #
    # @example Without details
    #
    #   reek_of(:FeatureEnvy)
    #   reek_of(Reek::Smells::UtilityFunction)
    #
    # @example With details
    #
    #   reek_of(:UncommunicativeParameterName, name: 'x2')
    #   reek_of(:DataClump, count: 3)
    #
    # @example From a real spec
    #
    #   expect(src).to reek_of(Reek::Smells::DuplicateMethodCall, name: '@other.thing')
    #
    # @public
    #
    # :reek:UtilityFunction
    def reek_of(smell_type,
                details: {},
                configuration: Configuration::AppConfiguration.default)
      ShouldReekOf.new(smell_type, details: details, configuration: configuration)
    end

    #
    # See the documentaton for "reek_of".
    #
    # Notable differences to reek_of:
    #   1.) "reek_of" doesn't mind if there are other smells of a different type.
    #       "reek_only_of" will fail in that case.
    #   2.) "reek_only_of" doesn't support the additional details hash.
    #
    # @public
    #
    # :reek:UtilityFunction
    def reek_only_of(smell_type, configuration: Configuration::AppConfiguration.default)
      ShouldReekOnlyOf.new(smell_type, configuration: configuration)
    end

    #
    # Returns +true+ if and only if the target source code contains smells.
    #
    # @param configuration [Reek::Configuration::AppConfiguration] The configuration that should be used.
    #
    # @public
    #
    # :reek:UtilityFunction
    def reek(configuration = Configuration::AppConfiguration.default)
      ShouldReek.new(configuration)
    end
  end
end

if Object.const_defined?(:Spec)
  Spec::Runner.configure do |config|
    config.include(Reek::Spec)
  end
end

if Object.const_defined?(:RSpec)
  RSpec.configure do |config|
    config.include(Reek::Spec)
  end
end
