require_relative '../cli/silencer'

Reek::CLI::Silencer.silently do
  require 'unparser'
end

module Reek
  module AST
    #
    # Formats snippets of syntax tree back into Ruby source code.
    #
    class SexpFormatter
      # Formats the given sexp.
      #
      # @param [AST::Node, #to_s] sexp - The expression to format
      #
      # @return [String] a formatted string representation.
      #
      # :reek:DuplicateMethodCall { max_calls: 2 } is ok for lines.first
      def self.format(sexp)
        return sexp.to_s unless sexp.is_a? ::Parser::AST::Node
        lines = Unparser.unparse(sexp).split "\n"
        case lines.length
        when 1 then lines.first
        when 2 then lines.join('; ')
        else [lines.first, lines.last].join(' ... ')
        end
      end
    end
  end
end
