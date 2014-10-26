require 'reek/spec/should_reek'
require 'reek/spec/should_reek_of'
require 'reek/spec/should_reek_only_of'

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
