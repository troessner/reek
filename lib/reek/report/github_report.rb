# frozen_string_literal: true

require_relative 'base_report'

module Reek
  module Report
    #
    # Displays smells as GitHub Workflow commands.
    #
    # @public
    #
    class GithubReport < BaseReport
      def show(out = $stdout)
        out.print(workflow_commands.join)
      end

      private

      def workflow_commands
        smells.map do |smell|
          WorkflowCommand.new(smell)
        end
      end

      # Represents a smell as a GitHub Workflow command.
      class WorkflowCommand
        def initialize(smell)
          @smell = smell
        end

        def to_s
          format(
            "::warning file=%<file>s,line=%<line>d::%<message>s\n",
            file: file,
            line: line,
            message: message)
        end

        private

        def file
          @smell.source
        end

        def line
          @smell.lines.first
        end

        def message
          @smell.base_message.gsub('%', '%25').gsub("\r", '%0D').gsub("\n", '%0A')
        end
      end
    end
  end
end
