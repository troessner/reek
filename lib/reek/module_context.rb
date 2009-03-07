require 'reek/code_context'

module Reek
  class ModuleContext < CodeContext

    def initialize(outer, exp)
      super
      @name = Name.new(exp[1])
    end

    def myself
      @myself ||= @outer.find_module(@name)
    end

    def find_module(modname)
      return nil unless myself
      sym = modname.to_s
      myself.const_defined?(sym) ? myself.const_get(sym) : nil
    end

    def outer_name
      "#{@outer.outer_name}#{@name}::"
    end

    def variable_names
      []
    end
  end
end
