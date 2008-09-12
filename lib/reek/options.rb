$:.unshift File.dirname(__FILE__)

require 'reek/report'
require 'optparse'

include Reek

module Reek

  class Options
    def self.default_options
      {:sort_order => Report::SORT_ORDERS[:context]}
    end
    
    @@opts = default_options

    def self.[](key)
      @@opts[key]
    end

    def self.parse_args(args)
      result = default_options
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] [files]"

        opts.separator ""
        opts.separator "Specific options:"

        opts.on('-s', "--sort ORDER", Report::SORT_ORDERS.keys,
          "Select sort order for report (#{Report::SORT_ORDERS.keys.join(', ')})") do |arg|
          result[:sort_order] = Report::SORT_ORDERS[arg] unless arg.nil?
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit(0)
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts "#{File.basename($0)} #{Reek::VERSION::STRING}"
          exit(0)
        end
      end

      parser.parse!(args)
      result
    end
    
    def self.parse(args)
      begin
        @@opts = parse_args(args)
      rescue OptionParser::ParseError => e
        puts "Error: #{e}"
        puts "Use '-h' for help."
        exit(1)
      end
    end
  end
end
