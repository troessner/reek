require 'reek/cli/options'
require 'reek/configuration/app_configuration'

module Reek
  module Cli
    #
    # Represents an instance of a Reek application.
    # This is the entry point for all invocations of Reek from the
    # command line.
    #
    class Application
      attr_reader :options

      STATUS_SUCCESS = 0
      STATUS_ERROR   = 1
      STATUS_SMELLS  = 2

      def initialize(argv)
        @status  = STATUS_SUCCESS
        @options = Options.new(argv)
        begin
          @command = @options.parse
          initialize_configuration
        rescue OptionParser::InvalidOption, Reek::Configuration::ConfigFileException => error
          $stderr.puts "Error: #{error}"
          @status = STATUS_ERROR
        end
      end

      def execute
        return @status if error_occured?
        @command.execute self
        @status
      end

      def initialize_configuration
        Configuration::AppConfiguration.initialize_with self
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

      private

      def error_occured?
        @status == STATUS_ERROR
      end
    end
  end
end
