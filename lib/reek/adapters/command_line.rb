require 'optparse'
require 'reek'
require 'reek/adapters/report'

module Reek
    
  # SMELL: Greedy Module
  # This creates the command-line parser AND invokes it. And for the
  # -v and -h options it also executes them. And it holds the config
  # options for the rest of the application.
  class Options

    CTX_SORT = '%m%c %w (%s)'
    SMELL_SORT = '%m[%s] %c %w'

    def initialize(argv)
      @argv = argv
      @parser = OptionParser.new
      @quiet = false
      @show_all = false
      @format = CTX_SORT
      @command = nil
      set_options
    end

    def parse
      @parser.parse!(@argv)
      @command ||= ReekCommand.new(@argv, @quiet, @format, @show_all)
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
        @command = VersionCommand.new(@parser)
      end

      @parser.separator "\nReport formatting:"

      @parser.on("-a", "--[no-]show-all", "Show all smells, including those masked by config settings") do |opt|
        @show_all = opt
      end
      @parser.on("-q", "--quiet", "Suppress headings for smell-free source files") do
        @quiet = true
      end
      @parser.on('-f', "--format FORMAT", 'Specify the format of smell warnings') do |arg|
        @format = arg unless arg.nil?
      end
      @parser.on('-c', '--context-first', "Sort by context; sets the format string to \"#{CTX_SORT}\"") do
        @format = CTX_SORT
      end
      @parser.on('-s', '--smell-first', "Sort by smell; sets the format string to \"#{SMELL_SORT}\"") do
        @format = SMELL_SORT
      end
    end

    def create_report(sniffers)
      @quiet ? QuietReport.new(sniffers, @format, @show_all) : FullReport.new(sniffers, @format, @show_all)
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
    def initialize(parser)
      @parser = parser
    end
    def execute
      puts "#{@parser.program_name} #{Reek::VERSION}"
      return EXIT_STATUS[:success]
    end
  end

  class ReekCommand
    def initialize(args, quiet, format, show_all)
      @args = args
      @quiet = quiet
      @format = format
      @show_all = show_all
    end

    def execute
      sniffer = @args.length > 0 ?
        @args.sniff :
        Reek::Sniffer.new($stdin.to_reek_source('$stdin'))
      rpt = @quiet ?
        QuietReport.new(sniffer.sniffers, @format, @show_all) :
        FullReport.new(sniffer.sniffers, @format, @show_all)
      puts rpt.report
      return EXIT_STATUS[sniffer.smelly? ? :smells : :success]
    end
  end
end
