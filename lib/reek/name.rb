module Reek
  class Name
    include Comparable

    def self.resolve(exp, context)
      return [context, new(exp)] unless Array === exp
      case exp[0]
      when :colon2
        mod = resolve(exp[1], context)[0]
        return [mod, new(exp[2])]
      when :const
        mod = ModuleContext.new(context, exp)
        return [mod, new(exp[2])]
      else
        return [context, new(exp[1])]
      end
    end

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
