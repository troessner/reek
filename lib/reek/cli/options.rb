# frozen_string_literal: true
require 'optparse'
require 'rainbow'
require_relative '../version'

module Reek
  module CLI
    #
    # Parses the command line
    #
    # See {file:docs/Command-Line-Options.md} for details.
    #
    # :reek:TooManyInstanceVariables: { max_instance_variables: 10 }
    # :reek:Attribute: { enabled: false }
    #
    class Options
      DEFAULT_SUCCESS_EXIT_CODE  = 0
      DEFAULT_ERROR_EXIT_CODE    = 1
      DEFAULT_FAILURE_EXIT_CODE  = 2

      attr_reader :argv, :parser, :smells_to_detect
      attr_accessor :colored,
                    :config_file,
                    :location_format,
                    :report_format,
                    :show_empty,
                    :show_links,
                    :sorting,
                    :success_exit_code,
                    :failure_exit_code,
                    :generate_todo_list

      def initialize(argv = [])
        @argv               = argv
        @parser             = OptionParser.new
        @report_format      = :text
        @location_format    = :numbers
        @show_links         = true
        @smells_to_detect   = []
        @colored            = color_support?
        @success_exit_code  = DEFAULT_SUCCESS_EXIT_CODE
        @failure_exit_code  = DEFAULT_FAILURE_EXIT_CODE
        @generate_todo_list = false

        set_up_parser
      end

      def parse
        parser.parse!(argv)
        Rainbow.enabled = colored
        self
      end

      private

      # :reek:UtilityFunction
      def color_support?
        $stdout.tty?
      end

      # :reek:TooManyStatements: { max_statements: 7 }
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
        parser.banner = <<-EOB.gsub(/^[ ]+/, '')
          Usage: #{program_name} [options] [files]

          Examples:

          #{program_name} lib/*.rb
          #{program_name} -s lib
          cat my_class.rb | #{program_name}

          See https://wiki.github.com/troessner/reek for detailed help.

        EOB
      end

      # :reek:TooManyStatements: { max_statements: 6 }
      def set_configuration_options
        parser.separator 'Configuration:'
        parser.on('-c', '--config FILE', 'Read configuration options from FILE') do |file|
          self.config_file = Pathname.new(file)
        end
        parser.on('--smell SMELL', 'Detect smell SMELL (default: all enabled smells)') do |smell|
          smells_to_detect << smell
        end
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
          '-f', '--format FORMAT', [:html, :text, :yaml, :json, :xml, :code_climate],
          'Report smells in the given format:',
          '  html', '  text (default)', '  yaml', '  json', '  xml', '  code_climate') do |opt|
          self.report_format = opt
        end
      end

      def set_report_formatting_options
        parser.separator "\nText format options:"
        set_up_color_option
        set_up_verbosity_options
        set_up_location_formatting_options
        set_up_sorting_option
      end

      def set_up_color_option
        parser.on('--[no-]color', 'Use colors for the output (default: true)') do |opt|
          self.colored = opt
        end
      end

      def set_up_verbosity_options
        parser.on('-V', '--[no-]empty-headings',
                  'Show headings for smell-free source files (default: false)') do |show_empty|
          self.show_empty = show_empty
        end
        parser.on('-U', '--[no-]wiki-links',
                  'Show link to related wiki page for each smell (default: true)') do |show_links|
          self.show_links = show_links
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

      def set_up_sorting_option
        parser.on('--sort-by SORTING', [:smelliness, :none],
                  'Sort reported files by the given criterium:',
                  '  smelliness ("smelliest" files first)',
                  '  none (default - output in processing order)') do |sorting|
          self.sorting = sorting
        end
      end

      # :reek:DuplicateMethodCall: { max_calls: 2 }
      def set_exit_codes
        parser.separator "\nExit codes:"
        parser.on('--success-exit-code CODE',
                  'The exit code when no smells are found '\
                  "(default: #{DEFAULT_SUCCESS_EXIT_CODE})") do |option|
          self.success_exit_code = Integer(option)
        end
        parser.on('--failure-exit-code CODE',
                  'The exit code when smells are found '\
                  "(default: #{DEFAULT_FAILURE_EXIT_CODE})") do |option|
          self.failure_exit_code = Integer(option)
        end
      end

      # :reek:TooManyStatements: { max_statements: 7 }
      def set_utility_options
        parser.separator "\nUtility options:"
        parser.on_tail('-h', '--help', 'Show this message') do
          puts parser
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
