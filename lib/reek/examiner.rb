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
    INCOMPREHENSIBLE_SOURCE_TEMPLATE = <<-EOS.freeze
      !!!
      Source %s can not be processed by Reek.
      This is most likely a Reek bug.
      It would be great if you could report this back to the Reek team
      by opening up a corresponding issue at https://github.com/troessner/reek/issues
      Make sure to include the source in question, the Reek version
      and the original exception below.

      Original exception:
      %s
      !!!
    EOS
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
    # @public
    def initialize(source,
                   filter_by_smells: [],
                   configuration: Configuration::AppConfiguration.default)
      @source           = Source::SourceCode.from(source)
      @collector        = CLI::WarningCollector.new
      @smell_types      = Smells::SmellRepository.eligible_smell_types(filter_by_smells)
      @smell_repository = Smells::SmellRepository.new(smell_types: @smell_types,
                                                      configuration: configuration.directive_for(description))
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
      run
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

    # Runs the Examiner on the given source to scan for code smells
    # and returns the corresponding Examiner instance.
    #
    # In case one of the smell detectors raises an exception we probably hit a Reek bug.
    # So we catch the exception here, let the user know something went wrong
    # and continue with the analysis.
    #
    # @return an instance of Examiner
    #
    # :reek:TooManyStatements: { max_statements: 6 }
    def run
      @run ||= begin
        syntax_tree = source.syntax_tree
        return self unless syntax_tree
        begin
          examine syntax_tree
        rescue StandardError => exception
          $stderr.puts format(INCOMPREHENSIBLE_SOURCE_TEMPLATE, source.origin, exception.inspect)
        else
          smell_repository.report_on(collector)
        end
        self
      end
    end

    def examine(syntax_tree)
      ContextBuilder.new(syntax_tree).context_tree.each do |element|
        smell_repository.examine(element)
      end
    end
  end
end
