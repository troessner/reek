# frozen_string_literal: true

require_relative 'code_context'

module Reek
  module Context
    #
    # A context wrapper for method calls found in a syntax tree.
    #
    class SendContext < CodeContext
      attr_reader :name

      def initialize(exp, name)
        @name = name
        super(exp)
      end

      def method_name_called_to_call
        return unless @name == :method

        local_nodes(:sym).map(&:name)
      end
    end
  end
end
