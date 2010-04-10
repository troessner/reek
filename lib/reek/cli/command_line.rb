require 'optparse'
require File.join(File.dirname(File.expand_path(__FILE__)), 'report')
require File.join(File.dirname(File.expand_path(__FILE__)), 'reek_command')
require File.join(File.dirname(File.expand_path(__FILE__)), 'help_command')
require File.join(File.dirname(File.expand_path(__FILE__)), 'version_command')
require File.join(File.dirname(File.expand_path(__FILE__)), 'yaml_command')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'source')

module Reek
  module Cli

    #
    # Parses the command line
    #
    class Options

      def initialize(argv)
        @argv = argv
        @parser = OptionParser.new
        @report_class = VerboseReport
        @command_class = ReekCommand
        @config_files = []
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
        #      -q|-[no-]quiet      Only list files that have smells
        #      files               Names of files or dirs to be checked
        #
        return <<EOB
Usage: #{progname} [options] [files]

Examples:

#{progname} lib/*.rb
#{progname} -q lib
cat my_class.rb | #{progname}

See http://wiki.github.com/kevinrutherford/reek for detailed help.

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

        @parser.separator "\nReport formatting:"
        @parser.on("-q", "--[no-]quiet", "Suppress headings for smell-free source files") do |opt|
          @report_class = opt ? QuietReport : VerboseReport
        end
        @parser.on("-y", "--yaml", "Report smells in YAML format") do
          @command_class = YamlCommand
          # SMELL: the args passed to the command should be tested, because it may
          # turn out that they are passed too soon, ie. before the files have been
          # separated out from the options
        end
      end

      def parse
        @parser.parse!(@argv)
        if @command_class == HelpCommand
          HelpCommand.new(@parser)
        elsif @command_class == VersionCommand
          VersionCommand.new(@parser.program_name)
        elsif @command_class == YamlCommand
          sources = get_sources
          YamlCommand.create(sources, @config_files)
        else
          sources = get_sources
          ReekCommand.create(sources, @report_class, @config_files)
        end
      end

      def get_sources
        if @argv.empty?
          return [$stdin.to_reek_source('$stdin')]
        else
          return Source::SourceLocator.new(@argv).all_sources
        end
      end
    end
  end
end
