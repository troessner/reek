require 'reek/code_context'

module Reek
  class YieldCallContext < CodeContext
    attr_reader :parameters

    def initialize(outer, exp)
      super
      @parameters = []
      args = exp[1]
      @parameters = args[0...-1] if args
    end
  end
end
