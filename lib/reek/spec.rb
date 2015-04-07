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
  module Spec
    #
    # Checks the target source code for instances of "smell category"
    # and returns true only if it can find one of them that matches.
    #
    # Remember that this includes our "smell types" as well. So it could be the
    # "smell type" UtilityFunction, which is represented as a concrete class
    # in reek but it could also be "Duplication" which is a "smell categgory".
    #
    # In theory you could pass many different types of input here:
    #   - :UtilityFunction
    #   - "UtilityFunction"
    #   - UtilityFunction (this works in our specs because we tend to do "include Reek:Smells")
    #   - Reek::Smells::UtilityFunction (the right way if you really want to pass a class)
    #   - "Duplication" or :Duplication which is an abstract "smell category"
    #
    # It is recommended to pass this as a symbol like :UtilityFunction. However we don't
    # enforce this.
    #
    # Additionally you can be more specific and pass in "smell_details" you
    # want to check for as well e.g. "name" or "count" (see the examples below).
    # The parameters you can check for are depending on the smell you are checking for.
    # For instance "count" doesn't make sense everywhere whereas "name" does in most cases.
    # If you pass in a parameter that doesn't exist (e.g. you make a typo like "namme") reek will
    # raise an ArgumentError to give you a hint that you passed something that doesn't make
    # much sense.
    #
    # smell_category - The "smell category" or "smell_type" we check for.
    # smells_details - A hash containing "smell warning" parameters
    #
    # Examples
    #
    #   Without smell_details:
    #
    #   reek_of(:FeatureEnvy)
    #   reek_of(Reek::Smells::UtilityFunction)
    #
    #   With smell_details:
    #
    #   reek_of(UncommunicativeParameterName, name: 'x2')
    #   reek_of(DataClump, count: 3)
    #
    # Examples from a real spec
    #
    #   expect(src).to reek_of(Reek::Smells::DuplicateMethodCall, name: '@other.thing')
    #
    def reek_of(smell_category, smell_details = {})
      ShouldReekOf.new(smell_category, smell_details)
    end

    #
    # See the documentaton for "reek_of".
    #
    # Notable differences to reek_of:
    #   1.) "reek_of" doesn't mind if there are other smells of a different category.
    #       "reek_only_of" will fail in that case.
    #   2.) "reek_only_of" doesn't support the additional smell_details hash.
    def reek_only_of(smell_category)
      ShouldReekOnlyOf.new(smell_category)
    end

    #
    # Returns +true+ if and only if the target source code contains smells.
    #
    def reek
      ShouldReek.new
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
