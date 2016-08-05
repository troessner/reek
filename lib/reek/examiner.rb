# frozen_string_literal: true
require_relative 'context_builder'
require_relative 'source/source_code'
require_relative 'cli/warning_collector'
require_relative 'smells/smell_repository'

module Reek
  #
  # Applies all available smell detectors to a source.
  #
  # @public
  #
  # :reek:TooManyInstanceVariables: { max_instance_variables: 7 }
  class Examiner
    #
    # Creates an Examiner which scans the given +source+ for code smells.
    #
    # @param source [File, IO, String]
    #   If +source+ is a String it is assumed to be Ruby source code;
    #   if it is a File or IO, it is opened and Ruby source code is read from it;
    #
    # @param filter_by_smells [Array<String>]
    #   List of smell types to filter by, e.g. "DuplicateMethodCall".
    #
    # @param configuration [Configuration::AppConfiguration]
    #   The configuration for this Examiner.
    #
    def initialize(source,
                   filter_by_smells: [],
                   configuration: Configuration::AppConfiguration.default)
      @source           = Source::SourceCode.from(source)
      @collector        = CLI::WarningCollector.new
      @smell_types      = Smells::SmellRepository.eligible_smell_types(filter_by_smells)
      @smell_repository = Smells::SmellRepository.new(smell_types: @smell_types,
                                                      configuration: configuration.directive_for(description))
    end

    #
    # Creates an Examiner, runs it on the given +source+ to scan for code smells
    # right away and returns the corresponding Examiner instance.
    #
    # This method takes the same parameters as +initialize+.
    # An example call could look like this:
    #
    #   Examiner.run('class Klass; def f; end; end', ["UncommunicativeMethodName"])
    #   Examiner.run('class Bad; end', ["DuplicateMethodCall"])
    #
    # @return an instance of Examiner
    #
    # @public
    def self.run(*args)
      new(*args).run
    end

    # :reek:TooManyStatements: { max_statements: 6 }
    def run
      @run ||= begin
        syntax_tree = source.syntax_tree
        return self unless syntax_tree
        ContextBuilder.new(syntax_tree).context_tree.each do |element|
          smell_repository.examine(element)
        end

        smell_repository.report_on(collector)
        self
      end
    end

    # FIXME: Should be named "origin"
    #
    # @return [String] description of the source being analysed
    #
    # @public
    def description
      @description ||= source.origin
    end

    #
    # @return [Array<SmellWarning>] the smells found in the source
    #
    # @public
    def smells
      @smells ||= collector.warnings
    end

    #
    # @return [Integer] the number of smells found in the source
    #
    # @public
    def smells_count
      smells.length
    end

    #
    # @return [Boolean] true if and only if there are code smells in the source.
    #
    # @public
    def smelly?
      !smells.empty?
    end

    private

    attr_reader :collector, :source, :smell_repository
  end
end
