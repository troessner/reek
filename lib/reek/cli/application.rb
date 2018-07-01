# frozen_string_literal: true

require_relative 'options'
require_relative 'status'
require_relative '../configuration/app_configuration'
require_relative '../configuration/configuration_file_finder'
require_relative '../source/source_locator'
require_relative 'command/report_command'
require_relative 'command/todo_list_command'
require_relative '../errors/config_file_error'

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
        @configuration = configure_app_configuration(options.config_file)
        @command = command_class.new(options: options,
                                     sources: sources,
                                     configuration: configuration)
      end

      def execute
        show_configuration_path
        command.execute
      end

      private

      attr_reader :command, :options

      def configure_options(argv)
        Options.new(argv).parse
      rescue OptionParser::InvalidOption => error
        warn "Error: #{error}"
        exit Status::DEFAULT_ERROR_EXIT_CODE
      end

      def configure_app_configuration(config_file)
        Configuration::AppConfiguration.from_path(config_file)
      rescue Errors::ConfigFileError => error
        warn "Error: #{error}"
        exit Status::DEFAULT_ERROR_EXIT_CODE
      end

      def show_configuration_path
        return unless options.show_configuration_path

        path = Configuration::ConfigurationFileFinder.find(path: options.config_file)
        if path
          puts "Using '#{path_relative_to_working_directory(path)}' as configuration file."
        else
          puts 'Not using any configuration file.'
        end
      end

      # Returns the path that is relative to the current working directory given an absolute path.
      # E.g. if the given absolute path is "/foo/bar/baz/.reek.yml" and your working directory is
      # "/foo/bar" this method would return "baz/.reek.yml"
      #
      # @param path [String] Absolute path
      # @return [Pathname], e.g. 'config/.reek.yml'
      #
      # :reek:UtilityFunction
      def path_relative_to_working_directory(path)
        Pathname(path).realpath.relative_path_from(Pathname.pwd)
      end

      def command_class
        options.generate_todo_list ? Command::TodoListCommand : Command::ReportCommand
      end

      def sources
        if no_source_files_given?
          if input_was_piped?
            disable_progress_output_unless_verbose
            source_from_pipe
          else
            working_directory_as_source
          end
        else
          sources_from_argv
        end
      end

      def argv
        options.argv
      end

      # @quality :reek:UtilityFunction
      def input_was_piped?
        !$stdin.tty?
      end

      def no_source_files_given?
        # At this point we have deleted all options from argv. The only remaining entries
        # are paths to the source files. If argv is empty, this means that no files were given.
        argv.empty?
      end

      def working_directory_as_source
        Source::SourceLocator.new(['.'], configuration: configuration, options: options).sources
      end

      def sources_from_argv
        Source::SourceLocator.new(argv, configuration: configuration, options: options).sources
      end

      def source_from_pipe
        [Source::SourceCode.from($stdin, origin: options.stdin_filename)]
      end

      def disable_progress_output_unless_verbose
        options.progress_format = :quiet unless options.show_empty
      end
    end
  end
end
