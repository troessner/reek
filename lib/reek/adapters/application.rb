require 'reek/adapters/command_line'
require 'reek/adapters/source'
require 'reek/adapters/core_extras'

module Reek

  EXIT_STATUS = {
    :success => 0,
    :error   => 1,
    :smells  => 2
  }

  #
  # Represents an instance of a Reek application.
  # This is the entry point for all invocations of Reek from the
  # command line.
  #
  class Application
    def initialize(argv)
      @options = Options.new(argv)
    end

    def examine_sources
      # SMELL: Greedy Method
      # Options.parse executes the -v and -h commands and throws a SystemExit
      args = @options.parse
      if args.length > 0
        @sniffer = args.sniff
      else
        @sniffer = Reek::Sniffer.new($stdin.to_reek_source('$stdin'))
      end
    end

    def reek
      examine_sources
      puts @options.create_report(@sniffer.sniffers).report
      return EXIT_STATUS[@sniffer.smelly? ? :smells : :success]
    end

    def execute
      begin
        return reek
      rescue SystemExit => ex
        return ex.status
      rescue Exception => error
        $stderr.puts "Error: #{error}"
        return EXIT_STATUS[:error]
      end
    end
  end
end
