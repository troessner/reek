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
    def initialize(source, smell_types_to_filter_by = [])
      sources = Source::SourceRepository.parse(source)
      @description = sources.description
      @collector = Core::WarningCollector.new

      smell_types = Core::SmellRepository.smell_types

      if smell_types_to_filter_by.any?
        smell_types.select! { |klass| smell_types_to_filter_by.include? klass.smell_type }
      end

      sources.each do |src|
        repository = Core::SmellRepository.new(src.desc, smell_types)
        Core::Sniffer.new(src, repository).report_on(@collector)
      end
    end

    #
    # List the smells found in the source.
    #
    # @return [Array<SmellWarning>]
    #
    def smells
      @smells ||= @collector.warnings
    end

    #
    # Returns the number of smells found in the source
    #
    def smells_count
      smells.length
    end

    #
    # True if and only if there are code smells in the source.
    #
    def smelly?
      !smells.empty?
    end
  end
end
