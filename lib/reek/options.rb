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
      parser = OptionParser.new do |opts|
        opts.banner = <<EOB
Usage: #{File.basename($0)} [options] SOURCES

The SOURCES may be any combination of file paths and Ruby source code.
EOB

        opts.separator ""
        opts.separator "Options:"

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit(0)
        end

        opts.on('-s', "--sort ORDER", Report::SORT_ORDERS.keys,
          "Select sort order for report (#{Report::SORT_ORDERS.keys.join(', ')})") do |arg|
          result[:sort_order] = Report::SORT_ORDERS[arg] unless arg.nil?
        end

        opts.on("-v", "--version", "Show version") do
          puts "#{File.basename($0)} #{Reek::VERSION::STRING}"
          exit(0)
        end
      end

      parser.parse!(args)
      result
    end
    
    def self.fatal_error(e) # :nodoc:
      puts "Error: #{e}"
      puts "Use '-h' for help."
      exit(1)
    end

    def self.parse(args)
      begin
        @@opts = parse_args(args)
        ARGV
      rescue OptionParser::ParseError => e
        fatal_error(e)
      end
    end
  end
end
