# NOTE: tree_walker is required first to ensure unparser is required before
# parser. This prevents a potentially incompatible version of parser from being
# loaded first. This is only relevant when running bin/reek straight from a
# checkout directory without using Bundler.
#
# See also https://github.com/troessner/reek/pull/468
require_relative 'tree_walker'
require_relative 'source/source_code'
require_relative 'cli/warning_collector'
require_relative 'smells/smell_repository'

module Reek
  #
  # Applies all available smell detectors to a source.
  #
  class Examiner
    #
    # Creates an Examiner which scans the given +source+ for code smells.
    #
    # @param source [File, IO, String]
    #   If +source+ is a String it is assumed to be Ruby source code;
    #   if it is a File or IO, it is opened and Ruby source code is read from it;
    #
    # @param filter_by_smells [Array<String>]
    #   List of smell types to filter by.
    #
    def initialize(source,
                   filter_by_smells = [],
                   configuration: Configuration::AppConfiguration.new)
      @source        = Source::SourceCode.from(source)
      @configuration = configuration
      @collector     = CLI::WarningCollector.new
      @smell_types   = eligible_smell_types(filter_by_smells)

      run
    end

    #
    # @return [String] description of the source being analysed
    #
    def description
      @description ||= source.description
    end

    #
    # @return [Array<SmellWarning>] the smells found in the source
    #
    def smells
      @smells ||= collector.warnings
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

    private_attr_reader :configuration, :collector, :smell_types, :source

    def run
      smell_repository = Smells::SmellRepository.new(source_description: description,
                                                     smell_types: smell_types,
                                                     configuration: configuration)
      syntax_tree = source.syntax_tree
      TreeWalker.new(smell_repository, syntax_tree).walk if syntax_tree
      smell_repository.report_on(collector)
    end

    def eligible_smell_types(filter_by_smells = [])
      if filter_by_smells.any?
        Smells::SmellRepository.smell_types.select do |klass|
          filter_by_smells.include? klass.smell_type
        end
      else
        Smells::SmellRepository.smell_types
      end
    end
  end
end
