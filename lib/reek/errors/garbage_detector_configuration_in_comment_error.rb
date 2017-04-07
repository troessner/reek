# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when trying to use a configuration for a detector
    # that can't be parsed into a hash.
    class GarbageDetectorConfigurationInCommentError < BaseError
      BAD_DETECTOR_CONFIGURATION_MESSAGE = <<-EOS.freeze

        Error: You are trying to configure the smell detector '%s'.
        Unfortunately we can not parse the configuration you have given.
        The source is '%s' and the comment belongs to the expression starting in line %d.
        Here's the original comment:

        %s

        Please see the Reek docs for:
          * how to configure Reek via source code comments: https://github.com/troessner/reek/blob/master/docs/Smell-Suppression.md
          * what smell detectors are available: https://github.com/troessner/reek/blob/master/docs/Code-Smells.md
        Update the offensive comment (or remove it if no longer applicable) and re-run Reek.

      EOS

      def initialize(detector_name:, source:, line:, original_comment:)
        message = format(BAD_DETECTOR_CONFIGURATION_MESSAGE,
                         detector_name,
                         source,
                         line,
                         original_comment)
        super message
      end
    end
  end
end
