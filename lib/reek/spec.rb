require 'reek/source'

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
  # Here's a spec that ensures there are no smell warnings in the current project:
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
  # And a more complex example, making use of one of the factory methods for
  # +Source+ so that the code is parsed and analysed only once:
  # 
  #   ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'.to_source
  #   ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
  #   ruby.should reek_of(:Duplication, /@other.thing.foo/)
  #   ruby.should_not reek_of(:FeatureEnvy)
  #
  module Spec
    class ShouldReek        # :nodoc:
      def matches?(actual)
        @source = actual.to_source
        @source.smelly?
      end
      def failure_message_for_should
        "Expected source to reek, but it didn't"
      end
      def failure_message_for_should_not
        "Expected no smells, but got:\n#{@source.report}"
      end
    end

    #
    # Returns +true+ if and only if the target source code contains smells.
    #
    def reek
      ShouldReek.new
    end

    class ShouldReekOf        # :nodoc:
      def initialize(klass, patterns)
        @klass = klass
        @patterns = patterns
      end
      def matches?(actual)
        @source = actual.to_source
        @source.has_smell?(@klass, @patterns)
      end
      def failure_message_for_should
        "Expected #{@source} to reek of #{@klass}, but it didn't"
      end
      def failure_message_for_should_not
        "Expected #{@source} not to reek of #{@klass}, but got:\n#{@source.report}"
      end
    end

    #
    # Checks the target source code for instances of +smell_class+,
    # and returns +true+ only if one of them has a report string matching
    # all of the +patterns+.
    #
    def reek_of(smell_class, *patterns)
      ShouldReekOf.new(smell_class, patterns)
    end

    class ShouldReekOnlyOf        # :nodoc:
      def initialize(klass, patterns)
        @klass = klass
        @patterns = patterns
      end
      def matches?(actual)
        @source = actual.to_source
        @source.report.length == 1 and @source.has_smell?(@klass, @patterns)
      end
      def failure_message_for_should
        "Expected source to reek only of #{@klass}, but got:\n#{@source.report}"
      end
      def failure_message_for_should_not
        "Expected source not to reek only of #{@klass}, but it did"
      end
    end

    #
    # As for reek_of, but the matched smell warning must be the only warning of
    # any kind in the target source code's Reek report.
    #
    def reek_only_of(smell_class, *patterns)
      ShouldReekOnlyOf.new(smell_class, patterns)
    end
  end
end

class File
  def to_source
    Reek::Source.from_f(self)
  end
end

class String
  def to_source
    Reek::Source.from_s(self)
  end
end

class Array
  def to_source
    Reek::Source.from_pathlist(self)
  end
end

module Reek
  class Source
    def to_source
      self
    end
  end
end

if Object.const_defined?(:Spec)
  Spec::Runner.configure do |config|
    config.include(Reek::Spec)
  end
end
