# frozen_string_literal: true

require_relative 'module_context'

module Reek
  module Context
    #
    # A context wrapper for any refinement blocks found in a syntax tree.
    #
    class RefinementContext < ModuleContext
      def full_name
        exp.call.args.first.name
      end
    end
  end
end
