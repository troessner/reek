require 'reek/sniffer'

module Reek

  class ReekCommand

    def initialize(sources, report_class, show_all)
      @sniffer = sources.length > 0 ? sources.sniff : sniff_stdin
      @report_class = report_class
      @show_all = show_all
    end

    def sniff_stdin
      Reek::Sniffer.new($stdin.to_reek_source('$stdin'))
    end

    def execute(view)
      rpt = @report_class.new(@sniffer.sniffers, @show_all)
      view.output(rpt.report)
      if @sniffer.smelly?
        view.report_smells
      else
        view.report_success
      end
    end
  end

end
