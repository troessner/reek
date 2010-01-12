require File.join(File.dirname(File.expand_path(__FILE__)), 'name')
require File.join(File.dirname(File.expand_path(__FILE__)), 'method_context')
require File.join(File.dirname(File.expand_path(__FILE__)), 'sexp_formatter')

module Reek

  #
  # A context wrapper for any singleton method definition found in a syntax tree.
  #
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
