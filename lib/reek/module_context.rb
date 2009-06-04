require 'reek/code_context'

module Reek
  class ModuleContext < CodeContext

    def ModuleContext.create(outer, exp)
      res = Name.resolve(exp[1], outer)
      ModuleContext.new(res[0], res[1])
    end

    def initialize(outer, name)
      super(outer, nil)
      @name = name
    end

    def myself
      @myself ||= @outer.find_module(@name)
    end

    def find_module(modname)
      return nil unless myself
      @myself.const_or_nil(modname.to_s)
    end

    def outer_name
      "#{@outer.outer_name}#{@name}::"
    end

    def variable_names
      []
    end
  end
end
