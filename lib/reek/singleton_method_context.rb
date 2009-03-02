require 'reek/name'
require 'reek/method_context'
require 'reek/sexp_formatter'

module Reek
  class SingletonMethodContext < MethodContext

    def initialize(outer, exp)
      super(outer, exp, false)
      @name = Name.new(exp[2])
      @receiver = SexpFormatter.format(exp[1])
      record_depends_on_self
    end

    def envious_receivers
      []
    end
    
    def outer_name
      "#{@outer.outer_name}#{@receiver}.#{@name}/"
    end

    def to_s
      "#{@outer.outer_name}#{@receiver}.#{@name}"
    end
  end
end
