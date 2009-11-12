require 'optparse'
require 'reek'
require 'reek/adapters/report'
require 'reek/help_command'
require 'reek/reek_command'
require 'reek/version_command'

module Reek

  class Options

    def initialize(argv)
      @argv = argv
      @parser = OptionParser.new
      @report_class = VerboseReport
      @show_all = false
      @command = nil
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
      #      -a|--[no-]show-all  Report masked smells
      #      -q|-[no-]quiet      Only list files that have smells
      #      files               Names of files or dirs to be checked
      #
      return <<EOB
Usage: #{progname} [options] [files]

Examples:

#{progname} lib/*.rb
#{progname} -q -a lib
cat my_class.rb | #{progname}

See http://wiki.github.com/kevinrutherford/reek for detailed help.

EOB
    end

    def parse
      @parser.parse!(@argv)
      @command ||= ReekCommand.new(@argv, @report_class, @show_all)
    end

    def set_options
      @parser.banner = banner
      @parser.separator "Common options:"
      @parser.on("-h", "--help", "Show this message") do
        @command = HelpCommand.new(@parser)
      end
      @parser.on("-v", "--version", "Show version") do
        @command = VersionCommand.new(@parser.program_name)
      end

      @parser.separator "\nReport formatting:"
      @parser.on("-a", "--[no-]show-all", "Show all smells, including those masked by config settings") do |opt|
        @show_all = opt
      end
      @parser.on("-q", "--[no-]quiet", "Suppress headings for smell-free source files") do |opt|
        @report_class = opt ? QuietReport : VerboseReport
      end
    end
  end

end
