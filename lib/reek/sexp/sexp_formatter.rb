require_relative '../cli/silencer'
Reek::CLI::Silencer.silently do
  require 'unparser'
end

module Reek
  module Sexp
    #
    # Formats snippets of syntax tree back into Ruby source code.
    #
    # :reek:DuplicateMethodCall { max_calls: 2 } is ok for lines.first
    class SexpFormatter
      def self.format(sexp)
        return sexp.to_s unless sexp.is_a? AST::Node
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
