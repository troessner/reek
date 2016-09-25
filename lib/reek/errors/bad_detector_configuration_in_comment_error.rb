# frozen_string_literal: true
module Reek
  module Errors
    # TODO
    class BadDetectorConfigurationInCommentError < RuntimeError
      BAD_DETECTOR_CONFIGURATION_MESSAGE = <<-EOS.freeze

      TODO %s %s %s %s

      EOS

      def initialize(detector:, source:, line:, original_comment:)
        message = format(BAD_DETECTOR_CONFIGURATION_MESSAGE,
                         detector,
                         source,
                         line,
                         original_comment)
        super message
      end
    end
  end
end
