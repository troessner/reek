require 'reek/examiner'

module Reek
  module Cli

    #
    # A command to collect smells from a set of sources and write them out in
    # YAML format.
    #
    class YamlCommand
      def self.create(sources, config_files)
        examiners = sources.map {|src| Examiner.new(src, config_files) }
        new(examiners)
      end

      def initialize(examiners)
        @examiners = examiners
      end

      def execute(view)
        smells = []
        @examiners.each {|examiner| smells += examiner.smells}
        if smells.empty?
          view.report_success
        else
          view.output(smells.to_yaml)
          view.report_smells
        end
      end
    end
  end
end
