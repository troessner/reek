require File.join(File.dirname(File.expand_path(__FILE__)), 'code_context')

module Reek

  #
  # A context wrapper for any block found in a syntax tree.
  #
  class BlockContext < CodeContext

    def initialize(outer, exp)
      super
      @name = 'block'
      @scope_connector = '/'
    end
  end
end
