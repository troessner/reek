require 'ruby2ruby'

module Reek
  module Source
    #
    # Formats snippets of syntax tree back into Ruby source code.
    #
    class SexpFormatter
      def self.format(sexp)
        return sexp.to_s unless sexp.is_a? Array
        sexp = Sexp.from_array(YAML.load(YAML.dump(sexp)))
        Ruby2Ruby.new.process(sexp)
      end
    end
  end
end
