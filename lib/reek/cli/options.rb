require 'optparse'
require 'ostruct'
require 'rainbow'
require 'reek/cli/option_interpreter'
require 'reek/version'

module Reek
  module Cli
    #
    # Parses the command line
    #
    class Options
      def initialize(argv)
        @argv    = argv
        @parser  = OptionParser.new
        @options = OpenStruct.new(colored: true, smells_to_detect: [])
        set_up_parser
      end

      def parse
        @parser.parse!(@argv)
        @options.argv = @argv
        Rainbow.enabled = @options.colored
        @options
      end

      private

      def set_up_parser
        set_banner
        set_configuration_options
        set_alternative_formatter_options
        set_report_formatting_options
        set_utility_options
      end

      def set_banner
        program_name = @parser.program_name
        @parser.banner = <<-EOB.gsub(/^[ ]+/, '')
          Usage: #{program_name} [options] [files]

          Examples:

          #{program_name} lib/*.rb
          #{program_name} -s lib
          cat my_class.rb | #{program_name}

          See http://wiki.github.com/troessner/reek for detailed help.

        EOB
      end

      def set_alternative_formatter_options
        @parser.separator "\nReport format:"
        @parser.on(
          '-f', '--format FORMAT', [:html, :text, :yaml, :json],
          'Report smells in the given format:',
          '  html', '  text (default)', '  yaml', '  json'
        ) do |opt|
          @options.report_format = opt
        end
      end

      def set_configuration_options
        @parser.separator 'Configuration:'
        @parser.on('-c', '--config FILE', 'Read configuration options from FILE') do |file|
          @options.config_file = file
        end
        @parser.on('--smell SMELL', 'Detect smell SMELL (default is all enabled smells)') do |smell|
          @options.smells_to_detect << smell
        end
      end

      def set_report_formatting_options
        @parser.separator "\nText format options:"
        set_up_color_option
        set_up_verbosity_options
        set_up_location_formatting_options
        set_up_sorting_option
      end

      def set_up_color_option
        @parser.on('--[no-]color', 'Use colors for the output (this is the default)') do |opt|
          @options.colored = opt
        end
      end

      def set_up_verbosity_options
        @parser.on('-V', '--[no-]empty-headings',
                   'Show headings for smell-free source files') do |show_empty|
          @options.show_empty = show_empty
        end
        @parser.on('-U', '--[no-]wiki-links',
                   'Show link to related Reek wiki page for each smell') do |show_links|
          @options.show_links = show_links
        end
      end

      def set_up_location_formatting_options
        @parser.on('-n', '--[no-]line-numbers',
                   'Show line numbers in the output (this is the default)') do |show_numbers|
          @options.location_format = show_numbers ? :numbers : :plain
        end
        @parser.on('-s', '--single-line',
                   'Show location in editor-compatible single-line-per-smell format') do
          @options.location_format = :single_line
        end
      end

      def set_up_sorting_option
        @parser.on('--sort-by SORTING', [:smelliness, :none],
                   'Sort reported files by the given criterium:',
                   '  smelliness ("smelliest" files first)',
                   '  none (default - output in processing order)') do |sorting|
                     @options.sorting = sorting
                   end
      end

      def set_utility_options
        @parser.separator "\nUtility options:"
        @parser.on_tail('-h', '--help', 'Show this message') do
          puts @parser
          exit
        end
        @parser.on_tail('-v', '--version', 'Show version') do
          puts "#{@parser.program_name} #{Reek::Version::STRING}\n"
          exit
        end
      end
    end
  end
end
