require File.join( File.dirname( File.expand_path(__FILE__)), 'masking_collection')

module Reek

  #
  # Finds the code smells in Ruby source code
  #
  class Examiner
    attr_accessor :description

    def initialize(source)
      sniffers = case source
      when Array
        @description = 'dir'
        SourceLocator.new(source).all_sniffers
      when Source
        @description = source.desc
        [Reek::Sniffer.new(source)]
      else
        src = source.to_reek_source
        @description = src.desc
        [Reek::Sniffer.new(src)]
      end
      @warnings = MaskingCollection.new
      sniffers.each {|sniffer| sniffer.report_on(@warnings)}
    end

    def all_active_smells
      @warnings.all_active_items.to_a
    end

    def all_smells
      @warnings.all_items
    end

    def num_active_smells
      @warnings.num_visible_items
    end

    def num_masked_smells
      @warnings.num_masked_items
    end

    def smelly?
      not all_active_smells.empty?
    end
  end
end
