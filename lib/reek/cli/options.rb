require 'optparse'
require 'ostruct'
require 'rainbow'
require_relative 'option_interpreter'
require_relative '../version'

module Reek
  module CLI
    #
    # Parses the command line
    #
    # See {file:docs/Command-Line-Options.md} for details.
    # @api private
    class Options
      def initialize(argv = [])
        @argv    = argv
        @parser  = OptionParser.new
        @options = OpenStruct.new(report_format: :text,
                                  location_format: :numbers,
                                  colored: color_support?,
                                  smells_to_detect: [])
        set_up_parser
      end

      def parse
        parser.parse!(argv)
        options.argv = argv
        Rainbow.enabled = options.colored
        options
      end

      private

      private_attr_reader :argv, :options, :parser

      def color_support?
        $stdout.tty?
      end

      def set_up_parser
        set_banner
        set_configuration_options
        set_alternative_formatter_options
        set_report_formatting_options
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

      def set_alternative_formatter_options
        parser.separator "\nReport format:"
        parser.on(
          '-f', '--format FORMAT', [:html, :text, :yaml, :json, :xml],
          'Report smells in the given format:',
          '  html', '  text (default)', '  yaml', '  json', '  xml'
        ) do |opt|
          options.report_format = opt
        end
      end

      def set_configuration_options
        parser.separator 'Configuration:'
        parser.on('-c', '--config FILE', 'Read configuration options from FILE') do |file|
          raise ArgumentError, "Config file #{file} doesn't exist" unless File.exist?(file)
          options.config_file = Pathname.new(file)
        end
        parser.on('--smell SMELL', 'Detect smell SMELL (default: all enabled smells)') do |smell|
          options.smells_to_detect << smell
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
          options.colored = opt
        end
      end

      def set_up_verbosity_options
        parser.on('-V', '--[no-]empty-headings',
                  'Show headings for smell-free source files (default: false)') do |show_empty|
          options.show_empty = show_empty
        end
        parser.on('-U', '--[no-]wiki-links',
                  'Show link to related wiki page for each smell (default: false)') do |show_links|
          options.show_links = show_links
        end
      end

      def set_up_location_formatting_options
        parser.on('-n', '--[no-]line-numbers',
                  'Show line numbers in the output (default: true)') do |show_numbers|
          options.location_format = show_numbers ? :numbers : :plain
        end
        parser.on('-s', '--single-line',
                  'Show location in editor-compatible single-line-per-smell format') do
          options.location_format = :single_line
        end
      end

      def set_up_sorting_option
        parser.on('--sort-by SORTING', [:smelliness, :none],
                  'Sort reported files by the given criterium:',
                  '  smelliness ("smelliest" files first)',
                  '  none (default - output in processing order)') do |sorting|
          options.sorting = sorting
        end
      end

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
