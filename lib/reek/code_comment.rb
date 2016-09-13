# frozen_string_literal: true
require 'yaml'
require_relative 'smells/smell_detector'
require_relative 'errors'

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
      @config            = Hash.new { |hash, key| hash[key] = {} }

      @original_comment.scan(CONFIGURATION_REGEX) do |detector, _option_string, options|
        unless Smells::SmellDetector.valid_detector?(detector)
          raise BadDetectorInCommentError, detector: detector,
                                           source: source,
                                           line: line,
                                           original_comment: @original_comment
        end
        @config.merge! detector => YAML.load(options || DISABLE_DETECTOR_CONFIGURATION)
      end
    end

    def descriptive?
      sanitized_comment.split(/\s+/).length >= MINIMUM_CONTENT_LENGTH
    end

    private

    attr_reader :original_comment

    def sanitized_comment
      @sanitized_comment ||= original_comment.
        gsub(CONFIGURATION_REGEX, '').
        gsub(SANITIZE_REGEX, ' ').
        strip
    end
  end
end
