require_relative 'options'
require_relative 'reek_command'
require_relative 'option_interpreter'
require_relative '../configuration/app_configuration'

module Reek
  module CLI
    #
    # Represents an instance of a Reek application.
    # This is the entry point for all invocations of Reek from the
    # command line.
    #
    class Application
      STATUS_SUCCESS = 0
      STATUS_ERROR   = 1
      STATUS_SMELLS  = 2
      attr_reader :configuration

      private_attr_accessor :status
      private_attr_reader :command, :options

      def initialize(argv)
        @status = STATUS_SUCCESS
        @options = configure_options(argv)
        @configuration = configure_app_configuration(options.config_file)
        @command = ReekCommand.new(OptionInterpreter.new(options))
      end

      def execute
        return status if error_occured?
        command.execute self
        status
      end

      def report_success
        self.status = STATUS_SUCCESS
      end

      def report_smells
        self.status = STATUS_SMELLS
      end

      private

      def error_occured?
        status == STATUS_ERROR
      end

      def configure_options(argv)
        Options.new(argv).parse
      rescue OptionParser::InvalidOption => error
        $stderr.puts "Error: #{error}"
        exit STATUS_ERROR
      end

      def configure_app_configuration(config_file)
        Configuration::AppConfiguration.from_path(config_file)
      rescue Reek::Configuration::ConfigFileException => error
        $stderr.puts "Error: #{error}"
        exit STATUS_ERROR
      end
    end
  end
end
