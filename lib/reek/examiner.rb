require File.join( File.dirname( File.expand_path(__FILE__)), 'masking_collection')

module Reek

  #
  # Finds the code smells in Ruby source code
  #
  class Examiner
    attr_accessor :sniffer, :description

    def initialize(source)
      @sniffer = case source
      when Array
        sniffers = SourceLocator.new(source).all_sniffers
        @description = 'dir'
        Reek::SnifferSet.new(sniffers, 'dir')
      else
        src = source.to_reek_source
        @description = src.desc
        Reek::Sniffer.new(src)
      end
      @cwarnings = MaskingCollection.new
      @sniffer.sniffers.each {|sniffer| sniffer.report_on(@cwarnings)}
    end

    def all_active_smells
      @cwarnings.all_active_items.to_a
    end

    def all_smells
      @cwarnings.all_items
    end

    def smelly?
      not all_smells.empty?
    end
  end
end
