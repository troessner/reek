require 'set'
require 'reek/code_context'

module Reek

  #
  # Represents a parameters in a method definition.
  #
  module ParameterSet
    def names
      return @names if @names
      return (@names = []) if empty?
      arg = slice(1)
      case slice(0)
      when :masgn
        @names = arg[1..-1].map {|lasgn| Name.new(lasgn[1]) }
      when :lasgn, :iasgn
        @names = [Name.new(arg)]
      end
    end
  end

  #
  # A context wrapper for anything in a syntax tree that can contain variable
  # declarations.
  #
  class VariableContainer < CodeContext
    def initialize(outer, exp)
      super
      @local_variables = Set.new
    end

    def record_local_variable(sym)
      @local_variables << Name.new(sym)
    end
  end

  #
  # A context wrapper for any block found in a syntax tree.
  #
  class BlockContext < VariableContainer

    def initialize(outer, exp)
      super
      @name = Name.new('block')
      @scope_connector = '/'
      @parameters = exp[2] || []
      @parameters.extend(ParameterSet)
    end
    
    def variable_names
      @parameters.names + @local_variables.to_a
    end
  end
end
