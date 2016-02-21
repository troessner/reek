# frozen_string_literal: true
require_relative 'options'
require_relative 'option_interpreter'
require_relative '../configuration/app_configuration'
require_relative 'command/report_command'
require_relative 'command/todo_list_command'

module Reek
  module CLI
    #
    # Represents an instance of a Reek application.
    # This is the entry point for all invocations of Reek from the
    # command line.
    #
    class Application
      attr_reader :configuration

      def initialize(argv)
        @options = configure_options(argv)
        @status = options.success_exit_code
        @configuration = configure_app_configuration(options.config_file)
        @command = command_class.new(OptionInterpreter.new(options))
      end

      def execute
        command.execute self
      end

      private

      attr_accessor :status
      attr_reader :command, :options

      def configure_options(argv)
        Options.new(argv).parse
      rescue OptionParser::InvalidOption => error
        $stderr.puts "Error: #{error}"
        exit Options::DEFAULT_ERROR_EXIT_CODE
      end

      def configure_app_configuration(config_file)
        Configuration::AppConfiguration.from_path(config_file)
      rescue Reek::Configuration::ConfigFileException => error
        $stderr.puts "Error: #{error}"
        exit Options::DEFAULT_ERROR_EXIT_CODE
      end

      def command_class
        options.generate_todo_list ? Command::TodoListCommand : Command::ReportCommand
      end
    end
  end
end
