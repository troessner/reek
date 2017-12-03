# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source
    class IncomprehensibleSourceError < BaseError
      TEMPLATE = 'Source %s cannot be processed by Reek.'.freeze

      LONG_TEMPLATE = <<-MESSAGE.freeze
        !!!
        %s

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

      def initialize(origin:)
        super format(TEMPLATE, origin)
      end

      def long_message
        format(LONG_TEMPLATE,
               message,
               cause.inspect,
               cause.backtrace.join("\n\t"))
      end
    end
  end
end
