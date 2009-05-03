require 'reek/code_context'

module Reek
  class YieldCallContext < CodeContext
    attr_reader :parameters

    def initialize(outer, exp)
      super
      @parameters = exp[1..-1]
    end
  end
end
