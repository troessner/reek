require 'reek/name'
require 'reek/method_context'
require 'reek/sexp_formatter'

module Reek
  class SingletonMethodContext < MethodContext

    def initialize(outer, exp)
      super(outer, exp)
      @name = Name.new(exp[2])
      @receiver = SexpFormatter.format(exp[1])
      @scope_connector = ""
      record_depends_on_self
    end

    def envious_receivers
      []
    end

    def full_name
      outer = @outer ? @outer.full_name : ''
      prefix = outer == '' ? '' : "#{outer}#"
      "#{prefix}#{@receiver}.#{@name}"
    end
  end
end
