require 'reek/code_context'

module Reek

  #
  # A context wrapper for any call to +yield+ found in a syntax tree.
  #
  class YieldCallContext < CodeContext
    attr_reader :parameters

    def initialize(outer, exp)
      super
      @parameters = exp[1..-1]
    end
  end
end
