
module Reek

  class HelpCommand
    def initialize(parser)
      @parser = parser
    end
    def execute(view)
      view.output(@parser.to_s)
      view.report_success
    end
  end

end
