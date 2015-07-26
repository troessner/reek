require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # A Nested Iterator occurs when a block contains another block.
    #
    # +NestedIterators+ reports failing methods only once.
    #
    # See {file:docs/Nested-Iterators.md} for details.
    # @api private
    class NestedIterators < SmellDetector
      # The name of the config field that sets the maximum depth
      # of nested iterators to be permitted within any single method.
      MAX_ALLOWED_NESTING_KEY = 'max_allowed_nesting'
      DEFAULT_MAX_ALLOWED_NESTING = 1

      # The name of the config field that sets the names of any
      # methods for which nesting should not be considered
      IGNORE_ITERATORS_KEY = 'ignore_iterators'
      DEFAULT_IGNORE_ITERATORS = []

      def self.default_config
        super.merge(
          MAX_ALLOWED_NESTING_KEY => DEFAULT_MAX_ALLOWED_NESTING,
          IGNORE_ITERATORS_KEY => DEFAULT_IGNORE_ITERATORS
        )
      end

      #
      # Checks whether the given +block+ is inside another.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        exp, depth = *find_deepest_iterator(ctx)

        if depth && depth > value(MAX_ALLOWED_NESTING_KEY, ctx, DEFAULT_MAX_ALLOWED_NESTING)
          [SmellWarning.new(self,
                            context: ctx.full_name,
                            lines: [exp.line],
                            message: "contains iterators nested #{depth} deep",
                            parameters: { name: ctx.full_name, count: depth })]
        else
          []
        end
        # BUG: no longer reports nesting outside methods (eg. in Optparse)
      end

      private

      private_attr_accessor :ignore_iterators

      def find_deepest_iterator(ctx)
        self.ignore_iterators = value(IGNORE_ITERATORS_KEY, ctx, DEFAULT_IGNORE_ITERATORS)

        find_iters(ctx.exp, 1).sort_by { |item| item[1] }.last
      end

      def find_iters(exp, depth)
        return [] unless exp
        exp.find_nodes([:block]).flat_map do |elem|
          find_iters_for_iter_node(elem, depth)
        end
      end

      def find_iters_for_iter_node(exp, depth)
        ignored = ignored_iterator? exp
        result = find_iters(exp.call, depth) +
          find_iters(exp.block, depth + (ignored ? 0 : 1))
        result << [exp, depth] unless ignored
        result
      end

      def ignored_iterator?(exp)
        name = exp.call.method_name.to_s
        ignore_iterators.any? { |pattern| /#{pattern}/ =~ name }
      end
    end
  end
end
