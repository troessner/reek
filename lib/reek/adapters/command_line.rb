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
      @report_class = FullReport
      @show_all = false
      @command = nil
      set_options
    end

    def banner
      progname = @parser.program_name
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
        @report_class = opt ? QuietReport : FullReport
      end
    end
  end

end
