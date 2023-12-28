# frozen_string_literal: true

require 'optparse'
require 'rainbow'
require_relative '../version'
require_relative 'status'
require_relative '../detector_repository'
require_relative '../documentation_link'

module Reek
  module CLI
    #
    # Parses the command line
    #
    # See {file:docs/Command-Line-Options.md} for details.
    #
    # @quality :reek:TooManyInstanceVariables { max_instance_variables: 13 }
    # @quality :reek:TooManyMethods { max_methods: 20 }
    # @quality :reek:Attribute { enabled: false }
    #
    class Options
      attr_reader :argv, :parser, :smells_to_detect
      attr_accessor :colored,
                    :config_file,
                    :location_format,
                    :progress_format,
                    :report_format,
                    :show_empty,
                    :show_links,
                    :sorting,
                    :stdin_filename,
                    :success_exit_code,
                    :failure_exit_code,
                    :generate_todo_list,
                    :force_exclusion,
                    :show_configuration_path

      def initialize(argv = [])
        @argv                    = argv
        @parser                  = OptionParser.new
        @report_format           = :text
        @location_format         = :numbers
        @progress_format         = tty_output? ? :dots : :quiet
        @show_links              = true
        @smells_to_detect        = []
        @colored                 = tty_output?
        @success_exit_code       = Status::DEFAULT_SUCCESS_EXIT_CODE
        @failure_exit_code       = Status::DEFAULT_FAILURE_EXIT_CODE
        @generate_todo_list      = false
        @force_exclusion         = false
        @show_configuration_path = false

        set_up_parser
      end

      def parse
        parser.parse!(argv)
        Rainbow.enabled = colored
        self
      end

      def force_exclusion?
        @force_exclusion
      end

      private

      # TTY output generally means the output will not undergo further
      # processing by a machine, but will be viewed by a human. This means
      # features like coloring can be safely enabled by default.
      #
      # @quality :reek:UtilityFunction
      def tty_output?
        $stdout.tty?
      end

      # @quality :reek:TooManyStatements { max_statements: 7 }
      def set_up_parser
        set_banner
        set_configuration_options
        set_generate_todo_list_options
        set_alternative_formatter_options
        set_report_formatting_options
        set_exit_codes
        set_utility_options
      end

      def set_banner
        program_name = parser.program_name
        parser.banner = <<-BANNER.gsub(/^ +/, '')
          Usage: #{program_name} [options] [files]

          Examples:

          #{program_name} lib/*.rb
          #{program_name} -s lib
          cat my_class.rb | #{program_name}

          See https://github.com/troessner/reek for detailed help.

        BANNER
      end

      # @quality :reek:TooManyStatements { max_statements: 10 }
      def set_configuration_options # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        parser.separator 'Configuration:'
        parser.on('-c', '--config FILE', 'Read configuration options from FILE') do |file|
          self.config_file = Pathname.new(file)
        end
        parser.on('--smell SMELL',
                  'Only look for a specific smell.',
                  'Call it like this: reek --smell MissingSafeMethod source.rb',
                  "Check out #{code_smell_documentation_link} " \
                  'for a list of smells') do |smell|
          smells_to_detect << smell
        end
        parser.on('--exclude-smell SMELL',
                  'Exclude a specific smell.',
                  'Call it like this: reek --exclude-smell MissingSafeMethod source.rb',
                  "Check out #{code_smell_documentation_link} " \
                  'for a list of smells') do |smell|
          smells_to_detect.append(*smell_detectors) if smells_to_detect.empty?
          smells_to_detect.delete(smell)
        end
        parser.on('--stdin-filename FILE',
                  'When passing code in via pipe, assume this filename when ' \
                  'checking file or directory rules in the config.') do |file|
          self.stdin_filename = file
        end
      end

      def code_smell_documentation_link
        @code_smell_documentation_link ||= DocumentationLink.build('Code Smells')
      end

      def smell_detectors
        @smell_detectors ||= Reek::SmellDetectors.constants.map(&:to_s)
      end

      def set_generate_todo_list_options
        parser.separator "\nGenerate a todo list:"
        parser.on('-t', '--todo', 'Generate a todo list') do
          self.generate_todo_list = true
        end
      end

      def set_alternative_formatter_options
        parser.separator "\nReport format:"
        parser.on(
          '-f', '--format FORMAT', [:html, :text, :yaml, :json, :xml],
          'Report smells in the given format:',
          '  html', '  text (default)', '  yaml', '  json', '  xml') do |opt|
          self.report_format = opt
        end
      end

      # @quality :reek:TooManyStatements { max_statements: 7 }
      def set_report_formatting_options
        parser.separator "\nText format options:"
        set_up_color_option
        set_up_verbosity_options
        set_up_location_formatting_options
        set_up_progress_formatting_options
        set_up_sorting_option
        set_up_force_exclusion_option
      end

      def set_up_color_option
        parser.on('--[no-]color', 'Use colors for the output (default: true)') do |opt|
          self.colored = opt
        end
      end

      # @quality :reek:TooManyStatements { max_statements: 6 }
      def set_up_verbosity_options
        parser.on('-V', '--[no-]empty-headings',
                  'Show headings for smell-free source files (default: false)') do |show_empty|
          self.show_empty = show_empty
        end
        parser.on('-U', '--[no-]documentation',
                  'Show link to related documentation page for each smell (default: true)') do |show_links|
          self.show_links = show_links
        end
        parser.on(nil, '--[no-]show-configuration-path',
                  'Show which configuration file Reek is using (default: false)') do |show_configuration_path|
          self.show_configuration_path = show_configuration_path
        end
      end

      def set_up_location_formatting_options
        parser.on('-n', '--[no-]line-numbers',
                  'Show line numbers in the output (default: true)') do |show_numbers|
          self.location_format = show_numbers ? :numbers : :plain
        end
        parser.on('-s', '--single-line',
                  'Show location in editor-compatible single-line-per-smell format') do
          self.location_format = :single_line
        end
      end

      def set_up_progress_formatting_options
        parser.on('-P', '--[no-]progress',
                  'Show progress of each source as it is examined (default: true)') do |show_progress|
          self.progress_format = show_progress ? :dots : :quiet
        end
      end

      def set_up_sorting_option
        parser.on('--sort-by SORTING', [:smelliness, :none],
                  'Sort reported files by the given criterium:',
                  '  smelliness ("smelliest" files first)',
                  '  none (default - output in processing order)') do |sorting|
          self.sorting = sorting
        end
      end

      def set_up_force_exclusion_option
        parser.on('--force-exclusion',
                  'Force excluding files specified in the configuration `exclude_paths`',
                  '  even if they are explicitly passed as arguments') do |force_exclusion|
          self.force_exclusion = force_exclusion
        end
      end

      # @quality :reek:DuplicateMethodCall { max_calls: 2 }
      def set_exit_codes
        parser.separator "\nExit codes:"
        parser.on('--success-exit-code CODE',
                  'The exit code when no smells are found ' \
                  "(default: #{Status::DEFAULT_SUCCESS_EXIT_CODE})") do |option|
          self.success_exit_code = Integer(option)
        end
        parser.on('--failure-exit-code CODE',
                  'The exit code when smells are found ' \
                  "(default: #{Status::DEFAULT_FAILURE_EXIT_CODE})") do |option|
          self.failure_exit_code = Integer(option)
        end
      end

      # @quality :reek:TooManyStatements { max_statements: 12 }
      def set_utility_options
        parser.separator "\nUtility options:"
        parser.on_tail('-h', '--help', 'Show this message') do
          puts parser
          exit
        end
        parser.on_tail('-l', '--list', 'List all available smell detectors') do
          puts "All available smell detectors:\n\n"
          puts DetectorRepository.available_detector_names
          puts "\nCheck out #{DocumentationLink.build('Code Smells')} " \
               'for a details on each detector'
          exit
        end
        parser.on_tail('-v', '--version', 'Show version') do
          puts "#{parser.program_name} #{Reek::Version::STRING}\n"
          exit
        end
      end
    end
  end
end
