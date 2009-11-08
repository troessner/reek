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
      @status = EXIT_STATUS[:success]
    end

    def execute
      begin
        cmd = @options.parse
        cmd.execute(self)
      rescue Exception => error
        $stderr.puts "Error: #{error}"
        @status = EXIT_STATUS[:error]
      end
      return @status
    end

    def output(text)
      puts text
    end

    def report_success
      @status = EXIT_STATUS[:success]
    end

    def report_smells
      @status = EXIT_STATUS[:smells]
    end
  end
end
