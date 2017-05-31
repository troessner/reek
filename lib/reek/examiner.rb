# frozen_string_literal: true

require_relative 'context_builder'
require_relative 'detector_repository'
require_relative 'errors/incomprehensible_source_error'
require_relative 'source/source_code'

module Reek
  #
  # Applies all available smell detectors to a source.
  #
  # @public
  class Examiner
    # Handles no errors
    class NullHandler
      def handle(_exception)
        false
      end
    end

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
                   configuration: Configuration::AppConfiguration.default,
                   detector_repository_class: DetectorRepository,
                   error_handler: NullHandler.new)
      @source              = Source::SourceCode.from(source)
      @smell_types         = detector_repository_class.eligible_smell_types(filter_by_smells)
      @detector_repository = detector_repository_class.new(smell_types: @smell_types,
                                                           configuration: configuration.directive_for(description))
      @error_handler       = error_handler
    end

    # @return [String] origin of the source being analysed
    #
    # @public
    def origin
      @origin ||= source.origin
    end

    # @return [String] description of the source being analysed
    #
    # @public
    # @deprecated Use origin
    def description
      origin
    end

    #
    # @return [Array<SmellWarning>] the smells found in the source
    #
    # @public
    def smells
      @smells ||= run.sort.uniq
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

    attr_reader :source, :detector_repository

    # Runs the Examiner on the given source to scan for code smells.
    #
    # In case one of the smell detectors raises an exception we probably hit a Reek bug.
    # So we catch the exception here, let the user know something went wrong
    # and continue with the analysis.
    #
    # @return [Array<SmellWarning>] the smells found in the source
    #
    # :reek:TooManyStatements { max_statements: 8 }
    def run
      if source.valid_syntax? && syntax_tree
        begin
          examine_tree
        rescue Errors::BaseError => exception
          raise unless @error_handler.handle exception
          []
        end
      else
        SmellDetectors::Syntax.smells_from_source(source)
      end
    end

    def syntax_tree
      @syntax_tree ||= source.syntax_tree
    end

    def examine_tree
      ContextBuilder.new(syntax_tree).context_tree.flat_map do |element|
        detector_repository.examine(element)
      end
    rescue Errors::BaseError
      raise
    rescue StandardError => exception
      raise Errors::IncomprehensibleSourceError, origin: origin, original_exception: exception
    end
  end
end
