# frozen_string_literal: true

require_relative 'base_error'
require_relative '../documentation_link'

module Reek
  module Errors
    # Gets raised when trying to configure a detector with an option
    # which is unknown to it.
    class BadDetectorConfigurationKeyInCommentError < BaseError
      UNKNOWN_SMELL_DETECTOR_MESSAGE = <<-MESSAGE

        Error: You are trying to configure the smell detector '%<detector>s'
        in one of your source code comments with the unknown option %<option>s.
        The source is '%<source>s' and the comment belongs to the expression starting in line %<line>d.
        Here's the original comment:

        %<comment>s

        Please see the Reek docs for:
          * how to configure Reek via source code comments: #{DocumentationLink.build('Smell Suppression')}
          * what basic options are available: #{DocumentationLink.build('Basic Smell Options')}
          * what custom options are available by checking the detector specific documentation in /docs
        Update the offensive comment (or remove it if no longer applicable) and re-run Reek.

      MESSAGE

      def initialize(detector_name:, offensive_keys:, source:, line:, original_comment:)
        message = format(UNKNOWN_SMELL_DETECTOR_MESSAGE,
                         detector: detector_name,
                         option: offensive_keys,
                         source: source,
                         line: line,
                         comment: original_comment)
        super message
      end
    end
  end
end
