require File.join( File.dirname( File.expand_path(__FILE__)), 'examiner')

module Reek

  #
  # A command to collect smells from a set of sources and write them out in
  # YAML format.
  #
  class YamlCommand
    def self.create(sources)
      examiners = sources.map {|src| Examiner.new(src) }
      new(examiners)
    end

    def initialize(examiners)
      @examiners = examiners
    end

    def execute(view)
      smells = []
      @examiners.each {|examiner| smells += examiner.all_smells}
      if smells.empty?
        view.report_success
      else
        view.output(smells.to_yaml)
        view.report_smells
      end
    end
  end

end
