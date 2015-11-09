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
    class NestedIterators < SmellDetector
      # Struct for conveniently associating iterators with their depth (that is, their nesting).
      Iterator = Struct.new :exp, :depth do
        include Comparable
        def <=>(other)
          depth <=> other.depth
        end
      end

      private_attr_accessor :ignore_iterators

      # The name of the config field that sets the maximum depth
      # of nested iterators to be permitted within any single method.
      MAX_ALLOWED_NESTING_KEY = 'max_allowed_nesting'
      DEFAULT_MAX_ALLOWED_NESTING = 1

      # The name of the config field that sets the names of any
      # methods for which nesting should not be considered
      IGNORE_ITERATORS_KEY = 'ignore_iterators'
      DEFAULT_IGNORE_ITERATORS = ['tap']

      def self.default_config
        super.merge(
          MAX_ALLOWED_NESTING_KEY => DEFAULT_MAX_ALLOWED_NESTING,
          IGNORE_ITERATORS_KEY => DEFAULT_IGNORE_ITERATORS
        )
      end

      #
      # Attempts to find the deepest nested iterator and warns if it's depth
      # is bigger than our allowed maximum.
      #
      # @return [Array<SmellWarning>]
      #
      # :reek:TooManyStatements: { max_statements: 6 }
      def inspect(ctx)
        configure_ignore_iterators(ctx)
        deepest_iterator = find_deepest_iterator ctx
        return [] unless deepest_iterator
        depth = deepest_iterator.depth
        return [] unless depth > max_nesting(ctx)

        [smell_warning(
          context: ctx,
          lines: [deepest_iterator.exp.line],
          message: "contains iterators nested #{depth} deep",
          parameters: { name: ctx.full_name, count: depth })]
      end

      private

      #
      # @return [Iterator|nil]
      #
      def find_deepest_iterator(ctx)
        exp = ctx.exp
        return nil unless exp.find_nodes([:block])
        scout(parent: exp, exp: exp, depth: 0).
          flatten.
          sort.
          last
      end

      # A little digression into parser's sexp is necessary here:
      #
      # Given
      #   foo.each() do ... end
      # this will end up as:
      #
      # "foo.each() do ... end" -> the iterator below
      # "each()"                -> the "call" below
      # "do ... end"            -> the "block" below
      #
      # @param parent [AST::Node] The parent iterator
      #
      # @param exp [AST::Node]
      #   The given expression to analyze.
      #   Will be nil on empty blocks so we'll return just the parent iterator
      #
      # @param depth [Integer]
      #
      # @return [Array<Iterator>]
      #
      def scout(parent: raise, exp: raise, depth: raise)
        return [Iterator.new(parent, depth)] unless exp
        iterators = exp.find_nodes([:block])
        return [Iterator.new(parent, depth)] if iterators.empty?
        iterators.map do |iterator|
          # 1st case: we recurse down the given block of the iterator. In this case
          # we need to check if we should increment the depth.
          # 2nd case: we recurse down the associated call of the iterator. In this case
          # the depth stays the same.
          scout(parent: iterator, exp: iterator.block, depth: increment_depth(iterator, depth)) +
            scout(parent: iterator, exp: iterator.call, depth: depth)
        end
      end

      def configure_ignore_iterators(ctx)
        self.ignore_iterators = value(IGNORE_ITERATORS_KEY, ctx, DEFAULT_IGNORE_ITERATORS)
      end

      def increment_depth(iterator, depth)
        ignored_iterator?(iterator) ? depth : depth + 1
      end

      def max_nesting(ctx)
        value(MAX_ALLOWED_NESTING_KEY, ctx, DEFAULT_MAX_ALLOWED_NESTING)
      end

      # :reek:FeatureEnvy
      def ignored_iterator?(exp)
        ignore_iterators.any? { |pattern| /#{pattern}/ =~ exp.call.method_name } ||
          exp.without_block_arguments?
      end
    end
  end
end
