require_relative '../examiner'
require_relative '../report/formatter'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has code smells.
    #
    # @api private
    class ShouldReek
      def initialize(configuration = Configuration::AppConfiguration.new)
        @configuration = configuration
      end

      def matches?(actual)
        self.examiner = Examiner.new(actual, configuration: configuration)
        examiner.smelly?
      end

      def failure_message
        "Expected #{examiner.description} to reek, but it didn't"
      end

      def failure_message_when_negated
        rpt = Report::Formatter.format_list(examiner.smells)
        "Expected no smells, but got:\n#{rpt}"
      end

      private

      private_attr_reader :configuration
      private_attr_accessor :examiner
    end
  end
end
