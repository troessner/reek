# frozen_string_literal: true

module Reek
  module AST
    #
    # An AST Builder for ruby parser.
    #
    class Builder < ::Parser::Builders::Default
      # This is a work around for parsing ruby code that has a string with invalid sequence as UTF-8.
      # See. https://github.com/whitequark/parser/issues/283
      def string_value(token)
        value(token)
      end
    end
  end
end
