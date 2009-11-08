
module Reek

  class VersionCommand
    def initialize(progname)
      @progname = progname
    end
    def execute(view)
      view.output("#{@progname} #{Reek::VERSION}")
      view.report_success
    end
  end

end
