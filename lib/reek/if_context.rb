require 'reek/code_context'

module Reek

  #
  # A context wrapper for any +if+ statement found in a syntax tree.
  #
  class IfContext < CodeContext
    attr_reader :if_expr
    
    def initialize(outer, exp)
      super
      @name = ''
      @scope_connector = ''
      @if_expr = exp[1]
    end
    
    def tests_a_parameter?
      @if_expr[0] == :lvar and has_parameter(@if_expr[1])
    end
  end
end
