# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when trying to configure a detector with an option
    # which is unknown to it.
    class BadDetectorConfigurationKeyInCommentError < BaseError
      UNKNOWN_SMELL_DETECTOR_MESSAGE = <<-EOS.freeze

        Error: You are trying to configure the smell detector '%s'
        in one of your source code comments with the unknown option %s.
        The source is '%s' and the comment belongs to the expression starting in line %d.
        Here's the original comment:

        %s

        Please see the Reek docs for:
          * how to configure Reek via source code comments: https://github.com/troessner/reek/blob/master/docs/Smell-Suppression.md
          * what basic options are available: https://github.com/troessner/reek/blob/master/docs/Basic-Smell-Options.md
          * what custom options are available by checking the detector specific documentation in /docs
        Update the offensive comment (or remove it if no longer applicable) and re-run Reek.

      EOS

      def initialize(detector_name:, offensive_keys:, source:, line:, original_comment:)
        message = format(UNKNOWN_SMELL_DETECTOR_MESSAGE,
                         detector_name,
                         offensive_keys,
                         source,
                         line,
                         original_comment)
        super message
      end
    end
  end
end
