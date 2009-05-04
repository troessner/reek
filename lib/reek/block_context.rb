require 'set'
require 'reek/code_context'

module Reek

  module ParameterSet
    def names
      return @names if @names
      return (@names = []) if empty?
      arg = slice(1)
      case slice(0)
      when :masgn
        @names = arg[1..-1].map {|lasgn| Name.new(lasgn[1]) }
      when :lasgn
        @names = [Name.new(arg)]
      end
    end

    def include?(name)
      names.include?(name)
    end
  end

  class BlockContext < CodeContext

    def initialize(outer, exp)
      super
      @name = Name.new('block')
      @parameters = exp[0] if exp
      @parameters ||= []
      @parameters.extend(ParameterSet)
      @local_variables = Set.new
    end

    def inside_a_block?
      true
    end

    def has_parameter(name)
      @parameters.include?(name) or @outer.has_parameter(name)
    end

    def nested_block?
      @outer.inside_a_block?
    end
    
    def record_local_variable(sym)
      @local_variables << Name.new(sym)
    end

    def outer_name
      "#{@outer.outer_name}#{@name}/"
    end
    
    def variable_names
      @parameters.names + @local_variables.to_a
    end
  end
end
