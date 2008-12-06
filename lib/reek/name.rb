module Reek
  class Name
    include Comparable

    def initialize(sym)
      @name = sym.to_s
    end

    def hash  # :nodoc:
      @name.hash
    end

    def <=>(other)  # :nodoc:
      @name <=> other.to_s
    end

    alias eql? <=>

    def effective_name
      @name.gsub(/^@*/, '')
    end

    def to_s
      @name
    end
  end
end
