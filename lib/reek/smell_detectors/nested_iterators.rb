# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # A Nested Iterator occurs when a block contains another block.
    #
    # +NestedIterators+ reports failing methods only once.
    #
    # See {file:docs/Nested-Iterators.md} for details.
    class NestedIterators < BaseDetector
      # Struct for conveniently associating iterators with their depth (that is, their nesting).
      Iterator = Struct.new :exp, :depth do
        def line
          exp.line
        end
      end

      # The name of the config field that sets the maximum depth
      # of nested iterators to be permitted within any single method.
      MAX_ALLOWED_NESTING_KEY = 'max_allowed_nesting'.freeze
      DEFAULT_MAX_ALLOWED_NESTING = 1

      # The name of the config field that sets the names of any
      # methods for which nesting should not be considered
      IGNORE_ITERATORS_KEY = 'ignore_iterators'.freeze
      DEFAULT_IGNORE_ITERATORS = ['tap'].freeze

      def self.default_config
        super.merge(
          MAX_ALLOWED_NESTING_KEY => DEFAULT_MAX_ALLOWED_NESTING,
          IGNORE_ITERATORS_KEY => DEFAULT_IGNORE_ITERATORS)
      end

      # Generates a smell warning for each independent deepest nesting depth
      # that is greater than our allowed maximum. This means if two iterators
      # with the same depth were found, we combine them into one warning and
      # merge the line information.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        find_violations.group_by(&:depth).map do |depth, group|
          lines = group.map(&:line)
          smell_warning(
            context: context,
            lines: lines,
            message: "contains iterators nested #{depth} deep",
            parameters: { depth: depth })
        end
      end

      private

      # Finds the set of independent most deeply nested iterators that are
      # nested more deeply than allowed.
      #
      # Here, independent means that if iterator A is contained within iterator
      # B, we only include A. But if iterators A and B are both contained in
      # iterator C, but A is not contained in B, nor B in A, both A and B are
      # included.
      #
      # @return [Array<Iterator>]
      #
      def find_violations
        find_candidates.select { |it| it.depth > max_allowed_nesting }
      end

      # Finds the set of independent most deeply nested iterators regardless of
      # nesting depth.
      #
      # @return [Array<Iterator>]
      #
      def find_candidates
        scout(exp: expression, depth: 0)
      end

      # A little digression into parser's sexp is necessary here:
      #
      # Given
      #   foo.each() do ... end
      # this will end up as:
      #
      # "foo.each() do ... end" -> one of the :block nodes
      # "each()"                -> the node's "call"
      # "do ... end"            -> the node's "block"
      #
      # @param exp [AST::Node]
      #   The given expression to analyze.
      #
      # @param depth [Integer]
      #
      # @return [Array<Iterator>]
      #
      # :reek:TooManyStatements: { max_statements: 6 }
      def scout(exp:, depth:)
        return [] unless exp
        exp.find_nodes([:block]).flat_map do |iterator|
          new_depth = increment_depth(iterator, depth)
          # 1st case: we recurse down the given block of the iterator. In this case
          # we need to check if we should increment the depth.
          # 2nd case: we recurse down the associated call of the iterator. In this case
          # the depth stays the same.
          nested_iterators = scout(exp: iterator.block, depth: new_depth) +
            scout(exp: iterator.call, depth: depth)
          if nested_iterators.empty?
            Iterator.new(iterator, new_depth)
          else
            nested_iterators
          end
        end
      end

      def ignore_iterators
        @ignore_iterators ||= value(IGNORE_ITERATORS_KEY, context)
      end

      def increment_depth(iterator, depth)
        ignored_iterator?(iterator) ? depth : depth + 1
      end

      def max_allowed_nesting
        @max_allowed_nesting ||= value(MAX_ALLOWED_NESTING_KEY, context)
      end

      # :reek:FeatureEnvy
      def ignored_iterator?(exp)
        ignore_iterators.any? { |pattern| /#{pattern}/ =~ exp.call.name } ||
          exp.without_block_arguments?
      end
    end
  end
end
