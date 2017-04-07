# frozen_string_literal: true

require_relative '../examiner'
require_relative '../report/formatter'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has code smells.
    #
    class ShouldReek
      def initialize(configuration: Configuration::AppConfiguration.default)
        @configuration = configuration
      end

      def matches?(source)
        self.examiner = Examiner.new(source, configuration: configuration)
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

      attr_reader :configuration
      attr_accessor :examiner
    end
  end
end
