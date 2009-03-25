module Reek
  class Name
    include Comparable

    def self.resolve(exp, context)
      return [context, new(exp)] unless Array === exp
      name = exp[1]
      case exp[0]
      when :colon2
        return [resolve(name, context)[0], new(exp[2])]
      when :const
        return [ModuleContext.create(context, exp), new(name)]
      when :colon3
        return [StopContext.new, new(name)]
      else
        return [context, new(name)]
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
