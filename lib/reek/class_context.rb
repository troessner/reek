$:.unshift File.dirname(__FILE__)

require 'reek/code_context'

module Reek
  class ClassContext < CodeContext
    attr_accessor :name

    def initialize(outer, exp)
      super
      @name = exp[1].to_s
      @superclass = exp[2]
      @parsed_methods = []
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end

    def num_methods
      @parsed_methods.length
    end

    def record_method(name)
      @parsed_methods << name.to_s
    end

    def outer_name
      "#{@outer.outer_name}#{@name}#"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end
  end
end
