require 'reek/cli/command_line'

module Reek
  module Cli

    #
    # Represents an instance of a Reek application.
    # This is the entry point for all invocations of Reek from the
    # command line.
    #
    class Application

      STATUS_SUCCESS = 0
      STATUS_ERROR   = 1
      STATUS_SMELLS  = 2

      def initialize(argv)
        @options = Options.new(argv)
        @status = STATUS_SUCCESS
      end

      def execute
        begin
          cmd = @options.parse
          cmd.execute(self)
        rescue Exception => error
          $stderr.puts "Error: #{error}"
          @status = STATUS_ERROR
        end
        return @status
      end

      def output(text)
        print text
      end

      def report_success
        @status = STATUS_SUCCESS
      end

      def report_smells
        @status = STATUS_SMELLS
      end

      def output_smells_total(total_smells_count)
        total_smells_message = "#{total_smells_count} total warning"
        total_smells_message += 's' unless total_smells_count == 1
        total_smells_message += "\n"
        output total_smells_message
      end
    end
  end
end
