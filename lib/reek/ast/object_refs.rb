# frozen_string_literal: true

module Reek
  # Represents functionality related to an Abstract Syntax Tree.
  module AST
    #
    # ObjectRefs is used in CodeContexts.
    # It manages and counts the references out of a method to other objects and to `self`.
    #
    # E.g. this code:
    #   def foo(thing)
    #     bar.call_me
    #     bar.maybe(thing.wat)
    #   end
    #
    # would make "@refs" below look like this after the TreeWalker has done his job:
    #   {
    #     :self=>[2, 3], # `bar.call_me` and `bar.maybe` count as refs to `self` in line 2 and 3
    #     :thing=>[3]    # `thing.wat` in `bar.maybe()` counts as one reference to `thing`
    #   }
    #
    class ObjectRefs
      def initialize
        @refs = Hash.new { |refs, name| refs[name] = [] }
      end

      # Records the references a given method in a CodeContext has including
      # `self` (see the example at the beginning of this file).
      #
      # @param name [Symbol] The name of the object that the method references or `self`.
      # @param line [Int] The line number where this reference occurs.
      #
      # @return [Int|nil] The line number that was added (which might be nil).
      def record_reference(name:, line: nil)
        refs[name] << line
      end

      # @return [Hash] The most popular references.
      # E.g. for
      #   { foo: [2], self: [2,3], bar: [3,4] }
      # this would return
      #   { self: [2,3], bar: [3,4] }
      def most_popular
        max = refs.values.map(&:size).max
        refs.select { |_name, refs| refs.size == max }
      end

      def references_to(name)
        refs[name]
      end

      def self_is_max?
        refs.empty? || most_popular.keys.include?(:self)
      end

      private

      attr_reader :refs
    end
  end
end
