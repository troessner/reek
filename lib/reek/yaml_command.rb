require File.join( File.dirname( File.expand_path(__FILE__)), 'sniffer')
require File.join( File.dirname( File.expand_path(__FILE__)), 'masking_collection')

module Reek

  #
  # A command to collect smells from a set of sources and write them out in
  # YAML format.
  #
  class YamlCommand
    def self.create(sources)
      sniffers = sources.map {|src| Reek::Sniffer.new(src)}
      new(sniffers)
    end

    def initialize(sniffers)
      @sniffers = sniffers
      @smells_found = MaskingCollection.new   # SMELL: indicates non-determinism in the stacks
    end

    def execute(view)
      @sniffers.each {|sniffer| sniffer.report_on(@smells_found)}
      all = @smells_found.all_items
      if all.empty?
        view.report_success
      else
        view.output(all.to_yaml)
        view.report_smells
      end
    end
  end

end
