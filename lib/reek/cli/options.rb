require 'optparse'
require 'rainbow'
require 'reek/cli/report'
require 'reek/cli/reek_command'
require 'reek/cli/help_command'
require 'reek/cli/version_command'
require 'reek/source'

module Reek
  module Cli

    #
    # Parses the command line
    #
    class Options

      def initialize(argv)
        @argv = argv
        @parser = OptionParser.new
        @colored = true
        @report_class = QuietReport
        @warning_formatter = WarningFormatterWithLineNumbers
        @command_class = ReekCommand
        @format = Report::DefaultFormat
        @config_files = []
        @sort_by_issue_count = false
        @smells_to_detect = []
        set_options
      end

      def banner
        progname = @parser.program_name
        # SMELL:
        # The following banner isn't really correct. Help, Version and Reek
        # are really sub-commands (in the git/svn sense) and so the usage
        # banner should show three different command-lines. The other
        # options are all flags for the Reek sub-command.
        #
        # reek -h|--help           Display a help message
        #
        # reek -v|--version        Output the tool's version number
        #
        # reek [options] files     List the smells in the given files
        #      -c|--config file    Specify file(s) with config options
        #      -n|--line-number    Prefix smelly lines with line numbers
        #      -q|-[no-]quiet      Only list files that have smells
        #      files               Names of files or dirs to be checked
        #
        return <<EOB
Usage: #{progname} [options] [files]

Examples:

#{progname} lib/*.rb
#{progname} -q lib
cat my_class.rb | #{progname}

See http://wiki.github.com/troessner/reek for detailed help.

EOB
      end

      def set_options
        @parser.banner = banner
        @parser.separator "Common options:"
        @parser.on("-h", "--help", "Show this message") do
          @command_class = HelpCommand
        end
        @parser.on("-v", "--version", "Show version") do
          @command_class = VersionCommand
        end

        @parser.separator "\nConfiguration:"
        @parser.on("-c", "--config FILE", "Read configuration options from FILE") do |file|
          @config_files << file
        end
        @parser.on("--smell SMELL", "Detect smell SMELL (default is all enabled smells)") do |smell|
          @smells_to_detect << smell
        end

        @parser.separator "\nReport formatting:"
        @parser.on("-o", "--[no-]color", "Use colors for the output (this is the default)") do |opt|
          @colored = opt
        end
        @parser.on("-q", "--quiet", "Suppress headings for smell-free source files (this is the default)") do |opt|
          @report_class = QuietReport
        end
        @parser.on("-V", "--no-quiet", "--verbose", "Show headings for smell-free source files") do |opt|
          @report_class = VerboseReport
        end
        @parser.on("-n", "--no-line-numbers", "Suppress line numbers from the output") do
          @warning_formatter = SimpleWarningFormatter
        end
        @parser.on("--line-numbers", "Show line numbers in the output (this is the default)") do
          @warning_formatter = WarningFormatterWithLineNumbers
        end
        @parser.on("-s", "--single-line", "Show IDE-compatible single-line-per-warning") do
          @warning_formatter = SingleLineWarningFormatter
        end
        @parser.on("-S", "--sort-by-issue-count", 'Sort by "issue-count", listing the "smelliest" files first') do
          @sort_by_issue_count = true
        end
        @parser.on("-y", "--yaml", "Report smells in YAML format") do
          @format = :yaml
        end
        @parser.on("-H", "--html", "Report smells in HTML format") do
          @format = :html
        end
      end

      def parse
        @parser.parse!(@argv)
        Rainbow.enabled = @colored
        @command_class.new(self)
      end

      attr_reader :config_files
      attr_reader :smells_to_detect

      def reporter
        @reporter ||= @report_class.new( {
          warning_formatter: @warning_formatter,
          report_formatter: ReportFormatter,
          format: @format,
          sort_by_issue_count: @sort_by_issue_count
        })
      end

      def get_sources
        if @argv.empty?
          return [$stdin.to_reek_source('$stdin')]
        else
          return Source::SourceLocator.new(@argv).all_sources
        end
      end

      def program_name
        @parser.program_name
      end

      def help_text
        @parser.to_s
      end
    end
  end
end
