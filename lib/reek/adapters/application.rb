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

    def execute
      begin
        cmd = @options.parse
        status = cmd.execute
      rescue Exception => error
        $stderr.puts "Error: #{error}"
        status = :error
      end
      return EXIT_STATUS[status]
    end
  end
end
