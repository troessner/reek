# frozen_string_literal: true

require_relative 'errors/base_error'

module Reek
  # Handles errors by logging to stderr
  class LoggingErrorHandler
    def handle(exception)
      case exception
      when Errors::BaseError
        warn exception.long_message
      else
        warn exception.message
      end
      true
    end
  end
end
