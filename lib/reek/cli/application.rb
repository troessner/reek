require_relative 'options'
require_relative 'reek_command'
require_relative '../configuration/app_configuration'

module Reek
  module CLI
    #
    # Represents an instance of a Reek application.
    # This is the entry point for all invocations of Reek from the
    # command line.
    #
    # @api private
    class Application
      STATUS_SUCCESS = 0
      STATUS_ERROR   = 1
      STATUS_SMELLS  = 2
      attr_reader :configuration

      def initialize(argv)
        @status = STATUS_SUCCESS
        options_parser = Options.new(argv)
        begin
          options = options_parser.parse
          @command = ReekCommand.new(OptionInterpreter.new(options))
          @configuration = Configuration::AppConfiguration.new(options)
        rescue OptionParser::InvalidOption, Reek::Configuration::ConfigFileException => error
          $stderr.puts "Error: #{error}"
          @status = STATUS_ERROR
        end
      end

      def execute
        return status if error_occured?
        command.execute self
        status
      end

      def output(text)
        print text
      end

      def report_success
        self.status = STATUS_SUCCESS
      end

      def report_smells
        self.status = STATUS_SMELLS
      end

      private

      private_attr_accessor :status
      private_attr_reader :command

      def error_occured?
        status == STATUS_ERROR
      end
    end
  end
end
