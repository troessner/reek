require 'optparse'
require 'reek'
require 'reek/adapters/report'

module Reek

  class Options

    def initialize(argv)
      @argv = argv
      @parser = OptionParser.new
      @quiet = false
      @show_all = false
      @command = nil
      set_options
    end

    def parse
      @parser.parse!(@argv)
      @command ||= ReekCommand.new(@argv, @quiet, @show_all)
    end

    def set_options
      @parser.banner = <<EOB
Usage: #{@parser.program_name} [options] [files]

Examples:

#{@parser.program_name} lib/*.rb
#{@parser.program_name} -q -a lib
cat my_class.rb | #{@parser.program_name}

See http://wiki.github.com/kevinrutherford/reek for detailed help.

EOB

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
      @parser.on("-q", "--quiet", "Suppress headings for smell-free source files") do
        @quiet = true
      end
    end
  end

  class HelpCommand
    def initialize(parser)
      @parser = parser
    end
    def execute
      puts @parser.to_s
      return EXIT_STATUS[:success]
    end
  end

  class VersionCommand
    def initialize(progname)
      @progname = progname
    end
    def execute
      puts "#{@progname} #{Reek::VERSION}"
      return EXIT_STATUS[:success]
    end
  end

  class ReekCommand

    SMELL_FORMAT = '%m%c %w (%s)'

    def initialize(args, quiet, show_all)
      @args = args
      @quiet = quiet
      @show_all = show_all
    end

    def execute
      sniffer = @args.length > 0 ?
        @args.sniff :
        Reek::Sniffer.new($stdin.to_reek_source('$stdin'))
      rpt = @quiet ?
        QuietReport.new(sniffer.sniffers, SMELL_FORMAT, @show_all) :
        FullReport.new(sniffer.sniffers, SMELL_FORMAT, @show_all)
      puts rpt.report
      return EXIT_STATUS[sniffer.smelly? ? :smells : :success]
    end
  end
end
