$:.unshift File.dirname(__FILE__)

require 'reek/code_context'

module Reek
  class ModuleContext < CodeContext

    def initialize(outer, exp)
      super
      @name = Name.new(exp[1])
    end

    def outer_name
      "#{@outer.outer_name}#{@name}::"
    end

    def variable_names
      []
    end
  end
end
