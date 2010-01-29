require File.join(File.dirname(File.expand_path(__FILE__)), 'core', 'masking_collection')
require File.join(File.dirname(File.expand_path(__FILE__)), 'core', 'sniffer')
require File.join(File.dirname(File.expand_path(__FILE__)), 'source')

module Reek

  #
  # Finds the code smells in Ruby source code.
  #
  class Examiner

    #
    # A simple description of the source being analysed for smells.
    # If the source is a single File, this will be the file's path.
    #
    attr_accessor :description

    #
    # Creates an Examiner which scans the given +source+ for code smells.
    #
    # The smells reported against any source file can be "masked" by
    # creating *.reek files. See TBS for details.
    #
    # @param [Source::SourceCode, Array<String>, #to_reek_source]
    #   If +source+ is a String it is assumed to be Ruby source code;
    #   if it is a File, the file is opened and parsed for Ruby source code;
    #   and if it is an Array, it is assumed to be a list of file paths,
    #   each of which is opened and parsed for source code.
    #
    def initialize(source)
      sniffers = case source
      when Array
        @description = 'dir'
        Source::SourceLocator.new(source).all_sources.map {|src| Core::Sniffer.new(src)}
      when Source::SourceCode
        @description = source.desc
        [Core::Sniffer.new(source)]
      else
        src = source.to_reek_source
        @description = src.desc
        [Core::Sniffer.new(src)]
      end
      @warnings = Core::MaskingCollection.new
      sniffers.each {|sniffer| sniffer.report_on(@warnings)}
    end

    #
    # Returns an Array of SmellWarning objects, one for each non-masked smell
    # in the source.
    #
    # @return [Array<SmellWarning>]
    #
    def all_active_smells
      @warnings.all_active_items.to_a
    end

    #
    # Returns an Array of SmellWarning objects, one for each smell
    # in the source; includes active smells and masked smells.
    #
    # @return [Array<SmellWarning>]
    #
    def all_smells
      @warnings.all_items
    end

    #
    # Returns the number of non-masked smells in the source.
    #
    def num_active_smells
      @warnings.num_visible_items
    end

    #
    # Returns the number of masked smells in the source.
    #
    def num_masked_smells
      @warnings.num_masked_items
    end

    #
    # True if and only if there are non-masked code smells in the given source.
    #
    def smelly?
      not all_active_smells.empty?
    end
  end
end
