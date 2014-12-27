require 'reek'
require 'reek/cli/command'

module Reek
  module Cli
    #
    # A command to report the application's current version number.
    #
    class VersionCommand < Command
      def execute(view)
        view.output("#{@options.program_name} #{Reek::VERSION}\n")
        view.report_success
      end
    end
  end
end
