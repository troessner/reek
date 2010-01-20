require 'ruby2ruby'

module Reek
  module Source

    #
    # Formats snippets of syntax tree back into Ruby source code.
    #
    class SexpFormatter
      def self.format(sexp)
        sexp = YAML::load(YAML::dump(sexp))
        Ruby2Ruby.new.process(sexp)
      end
    end
  end
end
