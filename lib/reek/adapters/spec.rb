require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'examiner')
require File.join(File.dirname(File.expand_path(__FILE__)), 'core_extras')
require File.join(File.dirname(File.expand_path(__FILE__)), 'report')

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
  # To check for specific smells, use something like this:
  # 
  #   ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'
  #   ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
  #   ruby.should reek_of(:Duplication, /@other.thing.foo/)
  #   ruby.should_not reek_of(:FeatureEnvy)
  #
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has code smells.
    #
    class ShouldReek        # :nodoc:
      def matches?(actual)
        @examiner = Examiner.new(actual)
        @examiner.smelly?
      end
      def failure_message_for_should
        "Expected #{@examiner.description} to reek, but it didn't"
      end
      def failure_message_for_should_not
        rpt = QuietReport.new(@examiner.sniffer.sniffers, false).report
        "Expected no smells, but got:\n#{rpt}"
      end
    end

    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell.
    #
    class ShouldReekOf        # :nodoc:
      def initialize(klass, patterns)
        @klass = klass
        @patterns = patterns
      end
      def matches?(actual)
        @examiner = Examiner.new(actual)
        @all_smells = @examiner.all_active_smells
        @all_smells.any? {|warning| warning.matches?(@klass, @patterns)}
      end
      def failure_message_for_should
        "Expected #{@examiner.description} to reek of #{@klass}, but it didn't"
      end
      def failure_message_for_should_not
        rpt = QuietReport.new(@examiner.sniffer.sniffers, false).report
        "Expected #{@examiner.description} not to reek of #{@klass}, but got:\n#{rpt}"
      end
    end

    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell and no others.
    #
    class ShouldReekOnlyOf < ShouldReekOf        # :nodoc:
      def matches?(actual)
        @examiner = Examiner.new(actual)
        @all_smells = @examiner.all_active_smells
        @all_smells.length == 1 and @all_smells[0].matches?(@klass, @patterns)
      end
      def failure_message_for_should
        rpt = QuietReport.new(@examiner.sniffer.sniffers, false).report
        "Expected #{@examiner.description} to reek only of #{@klass}, but got:\n#{rpt}"
      end
      def failure_message_for_should_not
        "Expected #{@examiner.description} not to reek only of #{@klass}, but it did"
      end
    end

    #
    # Returns +true+ if and only if the target source code contains smells.
    #
    def reek
      ShouldReek.new
    end

    #
    # Checks the target source code for instances of +smell_class+,
    # and returns +true+ only if one of them has a report string matching
    # all of the +patterns+.
    #
    def reek_of(smell_class, *patterns)
      ShouldReekOf.new(smell_class, patterns)
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

if Object.const_defined?(:Spec)
  Spec::Runner.configure do |config|
    config.include(Reek::Spec)
  end
end
