# frozen_string_literal: true

module Reek
  # Handles errors by logging to stderr
  class LoggingErrorHandler
    def handle(exception)
      warn exception
      true
    end
  end
end
