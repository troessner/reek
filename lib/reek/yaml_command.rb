require 'reek/sniffer'
require 'reek/masking_collection'

module Reek

  class YamlCommand
    def self.create(sources)
      sniffer = sources.length > 0 ? sources.sniff : Reek::Sniffer.new($stdin.to_reek_source('$stdin'))
      new(sniffer.sniffers)
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
