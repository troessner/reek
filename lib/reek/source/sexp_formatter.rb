old_verbose, $VERBOSE = $VERBOSE, nil
require 'unparser'
$VERBOSE = old_verbose

module Reek
  module Source
    #
    # Formats snippets of syntax tree back into Ruby source code.
    #
    class SexpFormatter
      def self.format(sexp)
        return sexp.to_s unless sexp.is_a? AST::Node
        lines = Unparser.unparse(sexp).split "\n"
        if lines.length > 1
          "#{lines.first} ... #{lines.last}"
        else
          lines.first
        end
      end
    end
  end
end
