$:.unshift File.dirname(__FILE__)

require 'reek/code_context'

module Reek
  class ModuleContext < CodeContext

    def initialize(outer, exp)
      super
      @name = exp[1].to_s
    end

    def outer_name
      "#{@outer.outer_name}#{@name}::"
    end
  end
end
