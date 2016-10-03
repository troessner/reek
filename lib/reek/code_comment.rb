# frozen_string_literal: true
require 'yaml'
require_relative 'smell_detectors/base_detector'
require_relative 'errors/bad_detector_in_comment_error'
require_relative 'errors/bad_detector_configuration_in_comment_error'

module Reek
  #
  # A comment header from an abstract syntax tree; found directly above
  # module, class and method definitions.
  #
  class CodeComment
    CONFIGURATION_REGEX = /
                          :reek: # prefix
                          (\w+)  # smell detector e.g.: UncommunicativeVariableName
                          (
                            :? # legacy separator
                            \s*
                            (\{.*?\}) # optional details in hash style e.g.: { max_methods: 30 }
                          )?
                         /x
    SANITIZE_REGEX                 = /(#|\n|\s)+/ # Matches '#', newlines and > 1 whitespaces.
    DISABLE_DETECTOR_CONFIGURATION = '{ enabled: false }'.freeze
    MINIMUM_CONTENT_LENGTH         = 2
    LEGACY_SEPARATOR               = ':'.freeze

    attr_reader :config

    #
    # @param comment [String] - the original comment as found in the source code
    # @param line [Integer] - start of the expression the comment belongs to
    # @param source [String] - Path to source file or "string"
    #
    def initialize(comment:, line: nil, source: nil)
      @original_comment  = comment
      @line              = line
      @source            = source
      @config            = Hash.new { |hash, key| hash[key] = {} }

      @original_comment.scan(CONFIGURATION_REGEX) do |detector, _option_string, options|
        escalate_bad_detector(detector) unless SmellDetectors::BaseDetector.valid_detector?(detector)

        begin
          parsed_options = YAML.load(options || DISABLE_DETECTOR_CONFIGURATION)
        rescue Psych::SyntaxError
          escalate_bad_detector_configuration(detector)
        end

        @config.merge! detector => parsed_options
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

    def escalate_bad_detector(detector)
      raise Errors::BadDetectorInCommentError, detector: detector,
                                               original_comment: original_comment,
                                               source: source,
                                               line: line
    end

    def escalate_bad_detector_configuration(detector)
      raise Errors::BadDetectorConfigurationInCommentError, detector: detector,
                                                            original_comment: original_comment,
                                                            source: source,
                                                            line: line
    end
  end
end
