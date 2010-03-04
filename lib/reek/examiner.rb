require File.join(File.dirname(File.expand_path(__FILE__)), 'core', 'masking_collection')
require File.join(File.dirname(File.expand_path(__FILE__)), 'core', 'sniffer')
require File.join(File.dirname(File.expand_path(__FILE__)), 'source')

module Reek

  class ActiveSmellsOnly
    def configure(detectors, config)
      detectors.adopt(config)
    end

    def smells_in(sources)
      Core::MaskingCollection.new.collect_from(sources, self).all_active_items.to_a
    end
  end

  class ActiveAndMaskedSmells
    def configure(detectors, config)
      detectors.push(config)
    end

    def smells_in(sources)
      Core::MaskingCollection.new.collect_from(sources, self).all_items
    end
  end

  #
  # Finds the active code smells in Ruby source code.
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
    # @param [#smells_in]
    #   The +collector+ will be asked to examine the sources and report
    #   an array of SmellWarning objects. The default collector is an
    #   instance of ActiveSmellsOnly, which completely ignores all smells
    #   that have been masked by configuration options.
    #
    def initialize(source, collector = ActiveSmellsOnly.new)
      sources = case source
      when Array
        @description = 'dir'
        Source::SourceLocator.new(source).all_sources
      when Source::SourceCode
        @description = source.desc
        [source]
      else
        src = source.to_reek_source
        @description = src.desc
        [src]
      end
      @smells = collector.smells_in(sources)
    end

    #
    # Returns an Array of SmellWarning objects, one for each active smell
    # in the source.
    #
    # @return [Array<SmellWarning>]
    #
    def smells
      @smells
    end

    #
    # Returns the number of non-masked smells in the source.
    #
    def num_smells
      @smells.length
    end

    #
    # True if and only if there are non-masked code smells in the given source.
    #
    def smelly?
      not @smells.empty?
    end
  end
end
