# frozen_string_literal: true

require_relative 'method_context'

module Reek
  module Context
    #
    # A context wrapper for any singleton method definition found in a syntax tree.
    #
    class SingletonMethodContext < MethodContext
      def singleton_method?
        true
      end

      def instance_method?
        false
      end

      def module_function?
        false
      end

      # Was this singleton method defined with an instance method-like syntax?
      def defined_as_instance_method?
        type == :def
      end

      def apply_current_visibility(current_visibility)
        super if defined_as_instance_method?
      end
    end
  end
end
