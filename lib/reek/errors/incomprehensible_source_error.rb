# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source
    class IncomprehensibleSourceError < BaseError
      INCOMPREHENSIBLE_SOURCE_TEMPLATE = <<-MESSAGE.freeze
        !!!
        Source %s cannot be processed by Reek.

        This is most likely a Reek bug.

        It would be great if you could report this back to the Reek team by opening a
        corresponding issue at https://github.com/troessner/reek/issues.

        Please make sure to include the source in question, the Reek version and the
        original exception below.

        Exception message:

        %s

        Original exception:

        %s

        !!!
      MESSAGE

      def initialize(origin:, original_exception:)
        message = format(INCOMPREHENSIBLE_SOURCE_TEMPLATE,
                         origin,
                         original_exception.inspect,
                         original_exception.backtrace.join("\n\t"))
        super message
      end
    end
  end
end
