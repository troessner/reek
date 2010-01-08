require 'reek/code_context'

module Reek

  #
  # A context wrapper for any block found in a syntax tree.
  #
  class BlockContext < CodeContext

    def initialize(outer, exp)
      super
      @name = Name.new('block')
      @scope_connector = '/'
    end
  end
end
