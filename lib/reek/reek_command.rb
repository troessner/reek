require 'reek/sniffer'

module Reek

  #
  # A command to collect smells from a set of sources and write them out in
  # text report format.
  #
  class ReekCommand

    def initialize(filenames, report_class, show_all)
      @sniffer = filenames.length > 0 ? filenames.sniff : sniff_stdin
      @report_class = report_class
      @show_all = show_all    #SMELL: boolean parameter
    end

    def sniff_stdin
      Reek::Sniffer.new($stdin.to_reek_source('$stdin'))
      # SMELL: duplication with YamlCommand
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
