# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source
    class IncomprehensibleSourceError < BaseError
      INCOMPREHENSIBLE_SOURCE_TEMPLATE = <<-EOS.freeze
        !!!
        Source %s can not be processed by Reek.

        This is most likely either a bug in your Reek configuration (config file or
        source code comments) or a Reek bug.

        Please double check your Reek configuration taking the original exception
        below into account -  you might have misspelled a smell detector for instance.
        (In the future Reek will handle configuration errors more gracefully, something
        we are working on already).

        If you feel that this is not a problem with your Reek configuration but with
        Reek itself it would be great if you could report this back to the Reek
        team by opening up a corresponding issue at https://github.com/troessner/reek/issues.

        Please make sure to include the source in question, the Reek version
        and the original exception below.

        Exception message:

        %s

        Original exception:

        %s

        !!!
      EOS

      def initialize(origin:, original_exception:)
        message = format(INCOMPREHENSIBLE_SOURCE_TEMPLATE,
                         origin,
                         original_exception.message,
                         original_exception.backtrace.join("\n\t"))
        super message
      end
    end
  end
end
