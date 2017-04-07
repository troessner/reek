# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when trying to configure a detector which is unknown to us.
    # This might happen for multiple reasons. The users might have a typo in
    # his comment or he might use a detector that does not exist anymore.
    class BadDetectorInCommentError < BaseError
      UNKNOWN_SMELL_DETECTOR_MESSAGE = <<-EOS.freeze

        Error: You are trying to configure an unknown smell detector '%s' in one
        of your source code comments.
        The source is '%s' and the comment belongs to the expression starting in line %d.
        Here's the original comment:

        %s

        Please see the Reek docs for:
          * how to configure Reek via source code comments: https://github.com/troessner/reek/blob/master/docs/Smell-Suppression.md
          * what smell detectors are available: https://github.com/troessner/reek/blob/master/docs/Code-Smells.md
        Update the offensive comment (or remove it if no longer applicable) and re-run Reek.

      EOS

      def initialize(detector_name:, source:, line:, original_comment:)
        message = format(UNKNOWN_SMELL_DETECTOR_MESSAGE,
                         detector_name,
                         source,
                         line,
                         original_comment)
        super message
      end
    end
  end
end
