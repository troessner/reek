# frozen_string_literal: true

require_relative 'code_context'
require_relative 'singleton_method_context'

module Reek
  module Context
    # Semi-transparent context to represent a metaclass while building the
    # context tree. This context will not be part of the resulting tree, but
    # will track context and visibility separately while building is in
    # progress.
    class GhostContext < ModuleContext
      attr_reader :children

      def register_with_parent(parent)
        @parent = parent
      end

      def append_child_context(child)
        real_parent = parent.append_child_context(child)
        super
        real_parent
      end

      # Return the correct class for child method contexts (representing nodes
      # of type `:def`). For GhostContext, this is the class that represents
      # singleton methods.
      def method_context_class
        SingletonMethodContext
      end

      # Return the correct class for child attribute contexts. For
      # GhostContext, this is the class that represents singleton attributes.
      def attribute_context_class
        SingletonAttributeContext
      end

      def track_visibility(visibility, names)
        visibility_tracker.track_visibility children: children,
                                            visibility: visibility,
                                            names: names
      end

      def record_use_of_self
        parent.record_use_of_self
      end

      def statement_counter
        parent.statement_counter
      end
    end
  end
end
