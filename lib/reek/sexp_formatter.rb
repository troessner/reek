require 'ruby2ruby'

module Reek
  class SexpFormatter
    def self.format(sexp)
      sexp = YAML::load(YAML::dump(sexp))
      Ruby2Ruby.new.process(sexp)
    end
  end
end
