require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A Nested Iterator occurs when a block contains another block.
    #
    # +NestedIterators+ reports failing methods only once.
    #
    class NestedIterators < SmellDetector

      SMELL_CLASS = self.name.split(/::/)[-1]
      SMELL_SUBCLASS = SMELL_CLASS
      # SMELL: should be a subclass of UnnecessaryComplexity
      NESTING_DEPTH_KEY = 'depth'

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
          smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [exp.line],
            "contains iterators nested #{depth} deep",
            @source, SMELL_SUBCLASS,
            {NESTING_DEPTH_KEY => depth})
          [smell]
        else
          []
        end
        # BUG: no longer reports nesting outside methods (eg. in Optparse)
      end

    private

      def find_deepest_iterator(ctx)
        @ignore_iterators = value(IGNORE_ITERATORS_KEY, ctx, DEFAULT_IGNORE_ITERATORS)

        find_iters(ctx.exp, 1).sort_by {|item| item[1]}.last
      end

      def find_iters(exp, depth)
        exp.map do |elem|
          next unless Sexp === elem
          case elem.first
          when :iter
            find_iters_for_iter_node(elem, depth)
          when :class, :defn, :defs, :module
            next
          else
            find_iters(elem, depth)
          end
        end.flatten(1).compact
      end

      def find_iters_for_iter_node(exp, depth)
        ignored = ignored_iterator? exp
        result = find_iters([exp.call], depth) +
          find_iters([exp.block], depth + (ignored ? 0 : 1))
        result << [exp, depth] unless ignored
        result
      end

      def ignored_iterator?(exp)
        name = exp.call.method_name.to_s
        @ignore_iterators.any? { |pattern| /#{pattern}/ === name }
      end
    end
  end
end
