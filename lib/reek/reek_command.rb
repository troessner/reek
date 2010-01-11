require 'reek/adapters/source_locator'
require 'reek/sniffer'

module Reek

  #
  # A command to collect smells from a set of sources and write them out in
  # text report format.
  #
  class ReekCommand
    def self.create(filenames, report_class, show_all)
      sniffers = SourceLocator.new(filenames).all_sniffers
      new(sniffers, report_class, show_all)
    end

    def initialize(sniffers, report_class, show_all)
      @sniffers = sniffers
      @report_class = report_class
      @show_all = show_all    #SMELL: boolean parameter
    end

    def execute(view)
      had_smells = false
      @sniffers.each do |sniffer|
        rpt = @report_class.new(sniffer, @show_all)
        had_smells ||= sniffer.smelly?
        view.output(rpt.report)
      end
      if had_smells
        view.report_smells
      else
        view.report_success
      end
    end
  end

end
