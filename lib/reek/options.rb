require 'optparse'
require 'reek/source'

module Reek
    
  class Options

    CTX_SORT = '%c %w (%s)'
    SMELL_SORT = '[%s] %c %w'

    def self.default_options
      {
        :format => CTX_SORT
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
      set_help_option(opts)
      set_sort_option(config, opts)
      set_version_option(opts)
    end

    def self.parse(args)
      begin
        @@opts = parse_args(args)
        if ARGV.length > 0
          return Source.from_pathlist(ARGV)
        else
          return Source.from_io($stdin, 'stdin')
        end
      rescue OptionParser::ParseError, SystemCallError => err
        fatal_error(err)
      end
    end

  private
    
    def self.set_version_option(opts)
      opts.on("-v", "--version", "Show version") do
        puts "#{opts.program_name} #{Reek::VERSION}"
        exit(0)
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
    
    def self.fatal_error(err) # :nodoc:
      puts "Error: #{err}"
      puts "Use '-h' for help."
      exit(1)
    end
    
  end
end
