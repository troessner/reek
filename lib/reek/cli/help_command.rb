require 'reek/cli/command'

module Reek
  module Cli
    #
    # A command to display usage information for this application.
    #
    class HelpCommand < Command
      def execute(view)
        view.output(@options.help_text)
        view.report_success
      end
    end
  end
end
