module Reek
  class ObjectSource < Source   # :nodoc:

    def self.unify(sexp)   # :nodoc:
      unifier = Unifier.new
      unifier.processors.each do |proc|
        proc.unsupported.delete :cfunc # HACK
      end
      return unifier.process(sexp[0])
    end

    def initialize(code, desc, sniffer)     # :nodoc:
      super
      @sniffer.disable(LargeClass)
    end

    def can_parse_objects?
      return true if Object.const_defined?(:ParseTree)
      begin
        require 'parse_tree'
        true
      rescue LoadError
        false
      end
    end

    def syntax_tree
      if can_parse_objects?
        ObjectSource.unify(ParseTree.new.parse_tree(@source))
      else
        throw ArgumentError.new('You must install the ParseTree gem to use this feature')
      end
    end
  end
end

class Object
  #
  # Constructs a Sniffer which examines this object for code smells.
  # (This feature is only enabled if you have the ParseTree gem installed.)
  #
  def sniff
    result = Sniffer.new
    ObjectSource.new(self, self.to_s, result)
    result
  end
end
