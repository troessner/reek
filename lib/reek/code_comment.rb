# frozen_string_literal: true

require 'yaml'

require_relative 'smell_detectors/base_detector'
require_relative 'errors/bad_detector_in_comment_error'
require_relative 'errors/bad_detector_configuration_key_in_comment_error'
require_relative 'errors/garbage_detector_configuration_in_comment_error'
require_relative 'errors/legacy_comment_separator_error'

module Reek
  #
  # A comment header from an abstract syntax tree; found directly above
  # module, class and method definitions.
  #
  class CodeComment
    CONFIGURATION_REGEX = /
                          :reek:     # prefix
                          (\w+)      # smell detector e.g.: UncommunicativeVariableName
                          (:?\s*)    # separator
                          (\{.*?\})? # details in hash style e.g.: { max_methods: 30 }
                         /x.freeze
    SANITIZE_REGEX                 = /(#|\n|\s)+/.freeze # Matches '#', newlines and > 1 whitespaces.
    DISABLE_DETECTOR_CONFIGURATION = '{ enabled: false }'
    MINIMUM_CONTENT_LENGTH         = 2

    attr_reader :config

    #
    # @param comment [String] the original comment as found in the source code
    # @param line [Integer] start of the expression the comment belongs to
    # @param source [String] Path to source file or "string"
    #
    def initialize(comment:, line: nil, source: nil)
      @original_comment  = comment
      @line              = line
      @source            = source
      @config            = Hash.new { |hash, key| hash[key] = {} }

      @original_comment.scan(CONFIGURATION_REGEX) do |detector_name, separator, options|
        escalate_legacy_separator separator
        validator = CodeCommentValidator.new(detector_name:    detector_name,
                                             original_comment: original_comment,
                                             line:             line,
                                             source:           source,
                                             options:          options)
        validator.validate
        @config.merge! detector_name => validator.parsed_options
      end
    end

    def descriptive?
      sanitized_comment.split(/\s+/).length >= MINIMUM_CONTENT_LENGTH
    end

    private

    attr_reader :original_comment, :source, :line

    def sanitized_comment
      @sanitized_comment ||= original_comment.
        gsub(CONFIGURATION_REGEX, '').
        gsub(SANITIZE_REGEX, ' ').
        strip
    end

    def escalate_legacy_separator(separator)
      return unless separator.start_with? ':'

      raise Errors::LegacyCommentSeparatorError.new(original_comment: original_comment,
                                                    source: source,
                                                    line: line)
    end

    #
    # A typical configuration via code comment looks like this:
    #
    #   :reek:DuplicateMethodCall { enabled: false }
    #
    # There are a lot of ways a user can introduce some errors here:
    #
    # 1.) Unknown smell detector
    # 2.) Garbage in the detector configuration like { thats: a: bad: config }
    # 3.) Unknown configuration keys (e.g. by doing a simple typo: "exclude" vs. "exlude" )
    # 4.) Bad data types given as values for those keys
    # This class validates [1], [2] and [3] at the moment but will also validate
    # [4] in the future.
    #
    # @quality :reek:TooManyInstanceVariables { max_instance_variables: 7 }
    class CodeCommentValidator
      #
      # @param detector_name [String] the detector class that was parsed out of the original
      #   comment, e.g. "DuplicateMethodCall" or "UnknownSmellDetector"
      # @param original_comment [String] the original comment as found in the source code
      # @param line [Integer] start of the expression the comment belongs to
      # @param source [String] path to source file or "string"
      # @param options [String] the configuration options as String for the detector that were
      #   extracted from the original comment
      def initialize(detector_name:, original_comment:, line:, source:, options:)
        @detector_name    = detector_name
        @original_comment = original_comment
        @line             = line
        @source           = source
        @options          = options
      end

      #
      # Method can raise the following errors:
      #   * Errors::LegacyCommentSeparatorError
      #   * Errors::BadDetectorInCommentError
      #   * Errors::GarbageDetectorConfigurationInCommentError
      #   * Errors::BadDetectorConfigurationKeyInCommentError
      # @return [undefined]
      def validate
        escalate_unknown_configuration_key
      end

      def parsed_options
        @parsed_options ||=
          if Psych::VERSION < '3.1.0'
            YAML.safe_load(options || CodeComment::DISABLE_DETECTOR_CONFIGURATION, [Regexp])
          else
            YAML.safe_load(options || CodeComment::DISABLE_DETECTOR_CONFIGURATION,
                           permitted_classes: [Regexp])
          end
      rescue Psych::SyntaxError
        raise Errors::GarbageDetectorConfigurationInCommentError.new(detector_name: detector_name,
                                                                     original_comment: original_comment,
                                                                     source: source,
                                                                     line: line)
      end

      private

      attr_reader :detector_name,
                  :original_comment,
                  :line,
                  :source,
                  :separator,
                  :options

      def escalate_unknown_configuration_key
        return if given_keys_legit?

        raise Errors::BadDetectorConfigurationKeyInCommentError.new(detector_name: detector_name,
                                                                    offensive_keys: configuration_keys_difference,
                                                                    original_comment: original_comment,
                                                                    source: source,
                                                                    line: line)
      end

      def detector_class
        @detector_class ||= SmellDetectors::BaseDetector.to_detector(detector_name)
      rescue NameError
        raise Errors::BadDetectorInCommentError.new(detector_name: detector_name,
                                                    original_comment: original_comment,
                                                    source: source,
                                                    line: line)
      end

      # @return [Boolean] comment uses legacy three-colon format
      def legacy_format?
        separator.start_with? ':'
      end

      # @return [Boolean] all keys in code comment are applicable to the detector in question
      def given_keys_legit?
        given_configuration_keys.subset? valid_detector_keys
      end

      # @return [Set] the configuration keys that are found in the code comment
      def given_configuration_keys
        parsed_options.keys.map(&:to_sym).to_set
      end

      # @return [String] all keys from the code comment that look bad
      def configuration_keys_difference
        given_configuration_keys.difference(valid_detector_keys).
          to_a.map { |key| "'#{key}'" }.
          join(', ')
      end

      # @return [Set] all keys that are legit for the given detector
      def valid_detector_keys
        detector_class.configuration_keys
      end
    end
  end
end
