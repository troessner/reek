require File.join( File.dirname( File.expand_path(__FILE__)), 'masking_collection')

module Reek

  #
  # Finds the code smells in Ruby source code
  #
  class Examiner
    attr_accessor :sniffer

    def initialize(source)
      @sniffer = source.sniff
      @cwarnings = MaskingCollection.new
      @sniffer.sniffers.each {|sniffer| sniffer.report_on(@cwarnings)}
    end

    def all_active_smells
      @cwarnings.all_active_items.to_a
    end

    def all_smells
      @cwarnings.all_items
    end

    def description
      @sniffer.desc
    end

    def smelly?
      @sniffer.smelly?
    end
  end
end
