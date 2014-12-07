require 'reek/examiner'

module Reek
  module Spec
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
        @all_smells = @examiner.smells
        @all_smells.any? { |warning| warning.matches?(@klass, @patterns) }
      end

      def failure_message
        "Expected #{@examiner.description} to reek of #{@klass}, but it didn't"
      end

      def failure_message_when_negated
        "Expected #{@examiner.description} not to reek of #{@klass}, but it did"
      end
    end

    #
    # Checks the target source code for instances of +smell_category+,
    # and returns +true+ only if one of them has a report string matching
    # all of the +patterns+.
    #
    def reek_of(smell_category, *patterns)
      ShouldReekOf.new(smell_category, patterns)
    end
  end
end
