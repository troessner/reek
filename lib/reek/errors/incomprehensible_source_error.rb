# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source
    class IncomprehensibleSourceError < BaseError
      TEMPLATE = 'Source %<source>s cannot be processed by Reek.'

      LONG_TEMPLATE = <<-MESSAGE
        !!!
        %<message>s

        This is most likely a Reek bug.

        It would be great if you could report this back to the Reek team by opening a
        corresponding issue at https://github.com/troessner/reek/issues.

        Please make sure to include the source in question, the Reek version,
        and this entire error message, including the original exception below.

        Exception message:

        %<exception>s

        Original exception:

        %<original>s

        !!!
      MESSAGE

      def initialize(origin:)
        super format(TEMPLATE, source: origin)
      end

      def long_message
        format(LONG_TEMPLATE,
               message: message,
               exception: cause.inspect,
               original: cause.backtrace.join("\n\t"))
      end
    end
  end
end
