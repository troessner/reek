require File.join( File.dirname( File.expand_path(__FILE__)), 'examiner')

module Reek

  #
  # A command to collect smells from a set of sources and write them out in
  # text report format.
  #
  class ReekCommand
    def self.create(sources, report_class, show_all)
      examiners = sources.map {|src| Examiner.new(src) }
      new(examiners, report_class, show_all)
    end

    def initialize(examiners, report_class, show_all)
      @examiners = examiners
      @report_class = report_class
      @show_all = show_all    #SMELL: boolean parameter
    end

    def execute(view)
      had_smells = false
      @examiners.each do |examiner|
        rpt = @report_class.new(examiner, @show_all)
        had_smells ||= examiner.smelly?
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
