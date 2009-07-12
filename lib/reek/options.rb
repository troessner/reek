require 'optparse'
require 'reek'
require 'reek/source'
require 'reek/spec'       # SMELL

module Reek
    
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
    
    @@opts = default_options

    def self.[](key)
      @@opts[key]
    end

    def self.parse_args(args)
      result = default_options
      parser = OptionParser.new { |opts| set_options(opts, result) }
      parser.parse!(args)
      result
    end

    def self.set_options(opts, config)
      opts.banner = <<EOB
Usage: #{opts.program_name} [options] files...

If no files are given, Reek reads source code from standard input.
See http://wiki.github.com/kevinrutherford/reek for detailed help.
EOB
      
      opts.separator "\nOptions:"
      set_all_options(opts, config)
    end

    # SMELL: Greedy Module
    # This creates the command-line parser AND invokes it. And for the
    # -v and -h options it also executes them. And it holds the config
    # options for the rest of the application.
    def self.parse(args)
      @@opts = parse_args(args)
      if args.length > 0
        return args.sniff
      else
        return Source.from_io($stdin, '$stdin').sniffer
      end
    end

  private

    def self.set_all_options(opts, config)
      set_show_all_option(opts, config)
      set_help_option(opts)
      set_sort_option(config, opts)
      set_version_option(opts)
    end
    
    def self.set_version_option(opts)
      opts.on("-v", "--version", "Show version") do
        puts "#{opts.program_name} #{Reek::VERSION}"
        exit(0)
      end
    end

    def self.set_show_all_option(opts, config)
      opts.on("-a", "--[no-]show-all", "Show all smells, including those masked by config settings") do |opt|
        config[:show_all] = opt
      end
      opts.on("-q", "--quiet", "Suppress headings for smell-free source files") do
        config[:quiet] = true
      end
    end

    def self.set_help_option(opts)
      opts.on("-h", "--help", "Show this message") do
        puts opts
        exit(0)
      end
    end

    def self.set_sort_option(config, opts)
      opts.on('-f', "--format FORMAT", 'Specify the format of smell warnings') do |arg|
        config[:format] = arg unless arg.nil?
      end
      opts.on('-c', '--context-first', "Sort by context; sets the format string to \"#{CTX_SORT}\"") do
        config[:format] = CTX_SORT
      end
      opts.on('-s', '--smell-first', "Sort by smell; sets the format string to \"#{SMELL_SORT}\"") do
        config[:format] = SMELL_SORT
      end
    end
  end
end
