require_relative 'source/source_repository'
require_relative 'core/warning_collector'
require_relative 'core/smell_repository'
require_relative 'core/tree_walker'

module Reek
  #
  # Applies all available smell detectors to a source.
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
    # @param [Source::SourceCode, Array<String>, #to_reek_source]
    #   If +source+ is a String it is assumed to be Ruby source code;
    #   if it is a File, the file is opened and parsed for Ruby source code;
    #   and if it is an Array, it is assumed to be a list of file paths,
    #   each of which is opened and parsed for source code.
    #
    def initialize(source, smell_types_to_filter_by = [])
      @sources      = Source::SourceRepository.parse(source)
      @description  = @sources.description
      @collector    = Core::WarningCollector.new
      @smell_types  = eligible_smell_types(smell_types_to_filter_by)

      run
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

    private

    def run
      @sources.each do |source|
        smell_repository = Core::SmellRepository.new(source.desc, @smell_types)
        syntax_tree = source.syntax_tree
        Core::TreeWalker.new(smell_repository).process(syntax_tree) if syntax_tree
        smell_repository.report_on(@collector)
      end
    end

    def eligible_smell_types(smell_types_to_filter_by = [])
      if smell_types_to_filter_by.any?
        Core::SmellRepository.smell_types.select do |klass|
          smell_types_to_filter_by.include? klass.smell_type
        end
      else
        Core::SmellRepository.smell_types
      end
    end
  end
end
