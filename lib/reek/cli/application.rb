require 'reek/cli/options'

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
        rescue OptionParser::InvalidOption, ConfigFileException => error
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
    end
  end
end
