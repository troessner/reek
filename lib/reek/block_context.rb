$:.unshift File.dirname(__FILE__)

require 'reek/code_context'

module Reek
  class BlockContext < CodeContext
    attr_reader :parameters, :local_variables

    def initialize(outer, exp)
      super
      @parameters = []
      @local_variables = []
      @name = Name.new('block')
    end

    def inside_a_block?
      true
    end
    
    def has_parameter(sym)
      parameters.include?(sym) or @outer.has_parameter(sym)
    end

    def nested_block?
      @outer.inside_a_block?
    end
    
    def record_parameter(sym)
      @parameters << Name.new(sym)
    end

    def outer_name
      "#{@outer.outer_name}#{@name}/"
    end
    
    def variable_names
      @parameters + @local_variables
    end
  end
end
