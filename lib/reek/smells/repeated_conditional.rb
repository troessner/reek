require_relative '../ast/node'
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # Simulated Polymorphism occurs when
    # * code uses a case statement (especially on a type field);
    # * or code has several if statements in a row
    #   (especially if they're comparing against the same value);
    # * or code uses instance_of?, kind_of?, is_a?, or ===
    #   to decide what type it's working with;
    # * or multiple conditionals in different places test the same value.
    #
    # Conditional code is hard to read and understand, because the reader must
    # hold more state in his head.
    # When the same value is tested in multiple places throughout an application,
    # any change to the set of possible values will require many methods and
    # classes to change. Tests for the type of an object may indicate that the
    # abstraction represented by that type is not completely defined (or understood).
    #
    # +RepeatedConditional+ checks for multiple conditionals
    # testing the same value throughout a single class.
    #
    # See {file:docs/Repeated-Conditional.md} for details.
    # @api private
    class RepeatedConditional < SmellDetector
      # The name of the config field that sets the maximum number of
      # identical conditionals permitted within any single class.
      MAX_IDENTICAL_IFS_KEY = 'max_ifs'
      DEFAULT_MAX_IFS = 2

      def self.smell_category
        'SimulatedPolymorphism'
      end

      BLOCK_GIVEN_CONDITION = ::Parser::AST::Node.new(:send, [nil, :block_given?])

      def self.contexts      # :nodoc:
        [:class]
      end

      def self.default_config
        super.merge(MAX_IDENTICAL_IFS_KEY => DEFAULT_MAX_IFS)
      end

      #
      # Checks the given class for multiple identical conditional tests.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        max_identical_ifs = value(MAX_IDENTICAL_IFS_KEY, ctx, DEFAULT_MAX_IFS)
        conditional_counts(ctx).select do |_key, lines|
          lines.length > max_identical_ifs
        end.map do |key, lines|
          occurs = lines.length
          expression = key.format_to_ruby
          SmellWarning.new self,
                           context: ctx.full_name,
                           lines: lines,
                           message: "tests #{expression} at least #{occurs} times",
                           parameters: { name: expression, count: occurs }
        end
      end

      #
      # Returns a Hash listing all of the conditional expressions in
      # the given syntax tree together with the number of times each
      # occurs. Ignores nested classes and modules.
      #
      def conditional_counts(sexp)
        result = Hash.new { |hash, key| hash[key] = [] }
        collector = proc do |node|
          next unless (condition = node.condition)
          next if condition == BLOCK_GIVEN_CONDITION
          result[condition].push(condition.line)
        end
        [:if, :case].each { |stmt| sexp.local_nodes(stmt, &collector) }
        result
      end
    end
  end
end
