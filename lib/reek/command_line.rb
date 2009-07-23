require 'optparse'
require 'reek'

module Reek
    
  # SMELL: Greedy Module
  # This creates the command-line parser AND invokes it. And for the
  # -v and -h options it also executes them. And it holds the config
  # options for the rest of the application.
  class Options

    CTX_SORT = '%m%c %w (%s)'
    SMELL_SORT = '%m[%s] %c %w'

    def self.default_options
      {
        :format => CTX_SORT,
        :show_all => false,
        :quiet => false
      }
    end

    # SMELL: Global Variable
    @@opts = default_options

    def self.[](key)
      @@opts[key]
    end

    def initialize(argv)
      @argv = argv
      @parser = OptionParser.new
      set_options
    end

    def parse
      @parser.parse!(@argv)
      @argv
    end

    def set_options
      @parser.banner = <<EOB
Usage: #{@parser.program_name} [options] [files]

Examples:

reek lib/*.rb
reek -q -a lib
cat my_class.rb | reek

See http://wiki.github.com/kevinrutherford/reek for detailed help.

EOB

      @parser.separator "Common options:"

      @parser.on("-h", "--help", "Show this message") do
        puts @parser
        exit(0)
      end
      @parser.on("-v", "--version", "Show version") do
        puts "#{@parser.program_name} #{Reek::VERSION}"
        exit(0)
      end

      @parser.separator "\nReport formatting:"

      @parser.on("-a", "--[no-]show-all", "Show all smells, including those masked by config settings") do |opt|
        @@opts[:show_all] = opt
      end
      @parser.on("-q", "--quiet", "Suppress headings for smell-free source files") do
        @@opts[:quiet] = true
      end
      @parser.on('-f', "--format FORMAT", 'Specify the format of smell warnings') do |arg|
        @@opts[:format] = arg unless arg.nil?
      end
      @parser.on('-c', '--context-first', "Sort by context; sets the format string to \"#{CTX_SORT}\"") do
        @@opts[:format] = CTX_SORT
      end
      @parser.on('-s', '--smell-first', "Sort by smell; sets the format string to \"#{SMELL_SORT}\"") do
        @@opts[:format] = SMELL_SORT
      end
    end
  end
end
