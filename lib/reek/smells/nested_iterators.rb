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
      # SMELL: should be a subclass of UnnecessaryComplexity

      #
      # Checks whether the given +block+ is inside another.
      # Remembers any smells found.
      #
      def examine_context(method_ctx)
        find_deepest_iterators(method_ctx).each do |iter|
          depth = iter[1]
          found(method_ctx, "contains iterators nested #{depth} deep", '',
            {'depth' => depth}, [iter[0].line])
        end
        # TODO: report the nesting depth and the innermost line
        # BUG: no longer reports nesting outside methods (eg. in Optparse)
      end

      def find_deepest_iterators(method_ctx)
        result = []
        find_iters(method_ctx.exp, 1, result)
        result.select {|item| item[1] >= 2}
      end

      def find_iters(exp, depth, result)
        exp.each do |elem|
          next unless Sexp === elem
          case elem.first
          when :iter
            find_iters([elem.call], depth, result)
            current = result.length
            find_iters([elem.block], depth+1, result)
            result << [elem, depth] if result.length == current
          when :class, :defn, :defs, :module
            next
          else
            find_iters(elem, depth, result)
          end
        end
      end
    end
  end
end
