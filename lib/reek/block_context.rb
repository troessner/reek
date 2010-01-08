require 'set'
require 'reek/code_context'

module Reek

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
    end
  end
end
