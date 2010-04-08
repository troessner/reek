require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

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
        super.adopt(
          MAX_ALLOWED_NESTING_KEY => DEFAULT_MAX_ALLOWED_NESTING,
          IGNORE_ITERATORS_KEY => DEFAULT_IGNORE_ITERATORS
        )
      end

      def initialize(source, config = NestedIterators.default_config)
        super(source, config)
      end

      #
      # Checks whether the given +block+ is inside another.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        find_deepest_iterators(ctx).each do |iter|
          depth = iter[1]
          smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [iter[0].line],
            "contains iterators nested #{depth} deep",
            @source, SMELL_SUBCLASS,
            {NESTING_DEPTH_KEY => depth})
          @smells_found << smell
          #SMELL: serious duplication
        end
        # TODO: report the nesting depth and the innermost line
        # BUG: no longer reports nesting outside methods (eg. in Optparse)
      end

      def find_deepest_iterators(method_ctx)
        ignoring = value(IGNORE_ITERATORS_KEY, method_ctx, DEFAULT_IGNORE_ITERATORS)
        result = []
        find_iters(method_ctx.exp, 1, ignoring, result)
        max_allowed_nesting = value(MAX_ALLOWED_NESTING_KEY, method_ctx, DEFAULT_MAX_ALLOWED_NESTING)
        result.select {|item| item[1] > max_allowed_nesting}
      end

      def find_iters(exp, depth, ignoring, result)
        exp.each do |elem|
          next unless Sexp === elem
          case elem.first
          when :iter
            find_iters([elem.call], depth, ignoring, result)
            current = result.length
            call = Source::SexpFormatter.format(elem.call)
            ignored = ignoring.any? { |ignore| /#{ignore}/ === call }
            find_iters([elem.block], depth + (ignored ? 0 : 1), ignoring, result)
            result << [elem, depth] if result.length == current unless ignored
          when :class, :defn, :defs, :module
            next
          else
            find_iters(elem, depth, ignoring, result)
          end
        end
      end
    end
  end
end
