require 'reek/core/sniffer'
require 'reek/core/warning_collector'
require 'reek/source/source_repository'

module Reek

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
    def initialize(source, config_files = [], smell_names = [])
      sources = Source::SourceRepository.parse(source)
      @description = sources.description
      collector = Core::WarningCollector.new

      smell_classes = Core::SmellRepository.smell_classes
      if smell_names.any?
        smell_classes.select! { |klass| smell_names.include? klass.smell_class_name }
      end

      sources.each do |src|
        repository = Core::SmellRepository.new(src.desc, smell_classes)
        Core::Sniffer.new(src, config_files, repository).report_on(collector)
      end
      @smells = collector.warnings
    end

    #
    # List the smells found in the source.
    #
    # @return [Array<SmellWarning>]
    #
    def smells
      @smells
    end

    #
    # Returns the number of smells found in the source
    #
    def smells_count
      @smells.length
    end

    #
    # True if and only if there are code smells in the source.
    #
    def smelly?
      not @smells.empty?
    end

    #
    # Returns an Array of SmellWarning objects, one for each non-masked smell
    # in the source.
    #
    # @deprecated Use #smells instead.
    #
    def all_active_smells
      @smells
    end

    #
    # Returns an Array of SmellWarning objects, one for each smell
    # in the source; includes active smells and masked smells.
    #
    # @return [Array<SmellWarning>]
    #
    # @deprecated Use #smells instead.
    #
    def all_smells
      @smells
    end

    #
    # Returns the number of non-masked smells in the source.
    #
    # @deprecated Use #smells instead.
    #
    def num_active_smells
      @smells.length
    end

    #
    # Returns the number of masked smells in the source.
    #
    # @deprecated Masked smells are no longer reported; this method always returns 0.
    #
    def num_masked_smells
      0
    end
  end
end
