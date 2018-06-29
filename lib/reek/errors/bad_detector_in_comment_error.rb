# frozen_string_literal: true

require_relative 'base_error'
require_relative '../documentation_link'

module Reek
  module Errors
    # Gets raised when trying to configure a detector which is unknown to us.
    # This might happen for multiple reasons. The users might have a typo in
    # his comment or he might use a detector that does not exist anymore.
    class BadDetectorInCommentError < BaseError
      UNKNOWN_SMELL_DETECTOR_MESSAGE = <<-MESSAGE

        Error: You are trying to configure an unknown smell detector '%<detector>s' in one
        of your source code comments.
        The source is '%<source>s' and the comment belongs to the expression starting in line %<line>d.
        Here's the original comment:

        %<comment>s

        Please see the Reek docs for:
          * how to configure Reek via source code comments: #{DocumentationLink.build('Smell Suppression')}
          * what smell detectors are available: #{DocumentationLink.build('Code Smells')}
        Update the offensive comment (or remove it if no longer applicable) and re-run Reek.

      MESSAGE

      def initialize(detector_name:, source:, line:, original_comment:)
        message = format(UNKNOWN_SMELL_DETECTOR_MESSAGE,
                         detector: detector_name,
                         source: source,
                         line: line,
                         comment: original_comment)
        super message
      end
    end
  end
end
