require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'examiner')

module Reek
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
        "Expected no smells, but got:\n#{list_smells(@examiner)}"
      end
      def list_smells(examiner)
        examiner.smells.map do |smell|
          "#{smell.report('%c %w (%s)')}"
        end.join("\n")
      end
    end

    #
    # Returns +true+ if and only if the target source code contains smells.
    #
    def reek
      ShouldReek.new
    end
  end
end
