# frozen_string_literal: true
require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source
    class ParseError < BaseError
      MESSAGE_TEMPLATE = '%s: %s: %s'.freeze

      def initialize(origin:, original_exception:)
        message = format(MESSAGE_TEMPLATE,
                         origin,
                         original_exception.class.name,
                         original_exception.message)
        super message
      end
    end
  end
end
