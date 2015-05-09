# NOTE: tree_walker is required first to ensure unparser is required before
# parser. This prevents a potentially incompatible version of parser from being
# loaded first. This is only relevant when running bin/reek straight from a
# checkout directory without using Bundler.
#
# See also https://github.com/troessner/reek/pull/468
require_relative 'tree_walker'
require_relative 'smell_repository'
require_relative 'warning_collector'
require_relative '../source/source_repository'

module Reek
  module Core
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
      # @param source [Source::SourceCode, Array<String>, #to_reek_source]
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
      # @return [Array<SmellWarning>] the smells found in the source
      #
      def smells
        @smells ||= @collector.warnings
      end

      #
      # @return [Integer] the number of smells found in the source
      #
      def smells_count
        smells.length
      end

      #
      # @return [Boolean] true if and only if there are code smells in the source.
      #
      def smelly?
        !smells.empty?
      end

      private

      def run
        @sources.each do |source|
          smell_repository = Core::SmellRepository.new(source.description, @smell_types)
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
end
