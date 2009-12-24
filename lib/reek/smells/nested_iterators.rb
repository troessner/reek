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

      def self.contexts      # :nodoc:
        [:defn, :defs]
      end

      #
      # Checks whether the given +block+ is inside another.
      # Remembers any smells found.
      #
      def examine_context(method_ctx)
        find_deepest_iterators(method_ctx).each do |iter|
          found(method_ctx, "contains iterators nested #{iter[1]} deep")
        end
        # TODO: report the nesting depth and the innermost line
      end

      def find_deepest_iterators(method_ctx, depth = 0)
        result = []
        find_iters(method_ctx.exp, 1, result)
        result.select {|item| item[1] >= 2}
      end

      def find_iters(exp, depth, result)
        exp.each do |elem|
          next unless Sexp === elem
          next if [:class, :defn, :defs, :module].include?(elem.first)
          if elem.first == :iter
            find_iters([elem.call], depth, result)
            current = result.length
            find_iters([elem.block], depth+1, result)
            result << [elem, depth] if result.length == current
          else
            find_iters(elem, depth, result)
          end
        end
      end
    end
  end
end
