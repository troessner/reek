require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/sexp_formatter'

module Reek
  module Smells

    #
    # Simulated Polymorphism occurs when
    # * code uses a case statement (especially on a type field);
    # * or code has several if statements in a row (especially if they're comparing against the same value);
    # * or code uses instance_of?, kind_of?, is_a?, or === to decide what type it's working with;
    # * or multiple conditionals in different places test the same value.
    #
    # Conditional code is hard to read and understand, because the reader must
    # hold more state in his head.
    # When the same value is tested in multiple places throughout an application,
    # any change to the set of possible values will require many methods and
    # classes to change. Tests for the type of an object may indicate that the
    # abstraction represented by that type is not completely defined (or understood).
    #
    # In the current implementation, Reek only checks for multiple conditionals
    # testing the same value throughout a single class.
    #
    class SimulatedPolymorphism < SmellDetector

      def self.contexts      # :nodoc:
        [:class]
      end

      # The name of the config field that sets the maximum number of
      # identical conditionals permitted within any single class.
      MAX_IDENTICAL_IFS_KEY = 'max_ifs'

      DEFAULT_MAX_IFS = 2

      def self.default_config
        super.adopt(MAX_IDENTICAL_IFS_KEY => DEFAULT_MAX_IFS)
      end

      def initialize(config = SimulatedPolymorphism.default_config)
        super(config)
      end

      #
      # Checks the given ClassContext for multiple identical conditional tests.
      # Remembers any smells found.
      #
      def examine_context(klass)
        conditional_counts(klass).each do |key, val|
          found(klass, "tests #{SexpFormatter.format(key)} at least #{val} times") if val > value(MAX_IDENTICAL_IFS_KEY, klass, DEFAULT_MAX_IFS)
        end
      end

      #
      # Returns a Hash listing all of the conditional expressions in
      # the given syntax tree together with the number of times each
      # occurs. Ignores nested classes and modules.
      #
      def conditional_counts(klass)
        result = Hash.new(0)
        collector = proc { |node|
          condition = node.condition
          result[condition] += 1 unless condition == s(:call, nil, :block_given?, s(:arglist))
        }
        [:if, :case].each {|stmt| klass.local_nodes(stmt, &collector) }
        result
      end
    end
  end
end
