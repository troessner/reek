$:.unshift File.dirname(__FILE__)

require 'reek/report'
require 'reek/version'
require 'optparse'

include Reek

module Reek

  class Options
    
    def self.default_options
      {
        :sort_order => Report::SORT_ORDERS[:context],
        :expressions => []
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
Usage: #{opts.program_name} [options] SOURCES

The SOURCES may be any combination of file paths and Ruby source code.
EOB
      
      opts.separator "\nOptions:"
      set_help_option(opts)
      set_sort_option(config, opts)
      set_version_option(opts)
    end

    def self.parse(args)
      begin
        @@opts = parse_args(args)
        ARGV
      rescue OptionParser::ParseError => err
        fatal_error(err)
      end
    end

  private
    
    def self.set_version_option(opts)
      opts.on("-v", "--version", "Show version") do
        puts "#{opts.program_name} #{Reek::VERSION::STRING}"
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
      sort_options = Report::SORT_ORDERS.keys
      opts.on('-s', "--sort ORDER", sort_options,
        "Select sort order for report (#{sort_options.join(', ')})") do |arg|
        config[:sort_order] = Report::SORT_ORDERS[arg] unless arg.nil?
      end
    end
    
    def self.fatal_error(err) # :nodoc:
      puts "Error: #{err}"
      puts "Use '-h' for help."
      exit(1)
    end
    
  end
end
