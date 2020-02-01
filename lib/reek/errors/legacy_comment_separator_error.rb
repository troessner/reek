# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised for old-style comment configuration format.
    class LegacyCommentSeparatorError < BaseError
      MESSAGE = <<-MESSAGE
        Error: You are using the legacy configuration format (including three
        colons) to configure Reek in one your source code comments.

        The source is '%<source>s' and the comment belongs to the expression
        starting in line %<line>d.

        Here's the original comment:

        %<comment>s

        Please see the Reek docs for information on how to configure Reek via
        source code comments: #{DocumentationLink.build('Smell Suppression')}

        Update the offensive comment and re-run Reek.

      MESSAGE

      def initialize(source:, line:, original_comment:)
        message = format(MESSAGE,
                         source: source,
                         line: line,
                         comment: original_comment)
        super message
      end
    end
  end
end
