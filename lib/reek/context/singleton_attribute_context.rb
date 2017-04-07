# frozen_string_literal: true

require_relative 'attribute_context'

module Reek
  module Context
    #
    # A context wrapper for any singleton attribute definition found in a
    # syntax tree.
    #
    class SingletonAttributeContext < AttributeContext
      def instance_method?
        false
      end
    end
  end
end
