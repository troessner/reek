# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source due to an EncodingError
    class EncodingError < BaseError
      ENCODING_ERROR_TEMPLATE = <<-MESSAGE.freeze
        !!!
        Source '%s' cannot be processed by Reek due to an encoding error in the source file.

        This is a problem that is outside of Reek's scope and should be fixed by you, the
        user, in order for Reek being able to continue.
        Check out this article for an idea on how to get started:
        https://www.justinweiss.com/articles/3-steps-to-fix-encoding-problems-in-ruby/

        Exception message:

        %s

        Original exception:

        %s

        !!!
      MESSAGE

      def initialize(origin:, original_exception:)
        message = format(ENCODING_ERROR_TEMPLATE,
                         origin,
                         original_exception.message,
                         original_exception.backtrace.join("\n\t"))
        super message
      end
    end
  end
end
