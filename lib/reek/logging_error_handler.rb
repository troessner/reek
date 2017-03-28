# frozen_string_literal: true

require_relative 'errors/bad_detector_configuration_key_in_comment_error'
require_relative 'errors/bad_detector_in_comment_error'
require_relative 'errors/garbage_detector_configuration_in_comment_error'
require_relative 'errors/incomprehensible_source_error'

module Reek
  # Handles errors by logging to stderr
  class LoggingErrorHandler
    def handle(exception)
      warn exception
      true
    end
  end
end
