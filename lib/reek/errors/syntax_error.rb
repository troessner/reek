# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source due to a SyntaxError
    class SyntaxError < BaseError
      TEMPLATE = "Source '%<source>s' cannot be processed by Reek due to a syntax error in the source file."

      LONG_TEMPLATE = <<-MESSAGE
        !!!
        %<message>s

        This is a problem that is outside of Reek's scope and should be fixed by you, the
        user, in order for Reek being able to continue.

        Things you can try:
        - Check the syntax of the problematic file
        - If the file is not in fact a Ruby file, exclude it in your .reek.yml file

        Exception message:

        %<exception>s

        Original backtrace:

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
