require 'reek'

module Reek
  module Cli

    #
    # A command to report the application's current version number.
    #
    class VersionCommand
      def initialize(progname)
        @progname = progname
      end
      def execute(view)
        view.output("#{@progname} #{Reek::VERSION}\n")
        view.report_success
      end
    end
  end
end
