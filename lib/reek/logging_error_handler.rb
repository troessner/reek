require_relative 'errors/bad_detector_configuration_key_in_comment_error'
require_relative 'errors/bad_detector_in_comment_error'
require_relative 'errors/garbage_detector_configuration_in_comment_error'
require_relative 'errors/incomprehensible_source_error'

module Reek
  # Handles selected errors by logging to stderr
  class LoggingErrorHandler
    def handle(exception)
      case exception
      when Errors::BadDetectorInCommentError,
        Errors::GarbageDetectorConfigurationInCommentError,
        Errors::BadDetectorConfigurationKeyInCommentError,
        Errors::IncomprehensibleSourceError
        warn exception
        true
      else
        false
      end
    end
  end
end
