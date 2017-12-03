# frozen_string_literal: true

module Reek
  module Errors
    # Base class for all runtime Reek errors
    class BaseError < ::RuntimeError
      def long_message
        message
      end
    end
  end
end
