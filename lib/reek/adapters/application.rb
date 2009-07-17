require 'reek/adapters/command_line'

module Reek
  #
  # Represents an instance of a Reek application.
  # This is the entry point for all invocations of Reek from the
  # command line.
  #
  class Application
    def initialize(argv)
      @argv = argv
    end

    def execute
      begin
        # SMELL: Greedy Method
        # Options.parse executes the -v and -h commands and throws a SystemExit
        @sniffer = Reek::Options.parse(@argv)
        # SMELL:
        # This should use the actual type of report selected by the user's options
        puts @sniffer.full_report
        return @sniffer.smelly? ? 2 : 0
      rescue SystemExit => ex
        return ex.status
      rescue Exception => error
        $stderr.puts "Error: #{error}"
        return 1
      end
    end
  end
end
