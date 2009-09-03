require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/sexp_formatter'

module Reek
  module Smells

    #
    # A Data Clump occurs when the same two or three items frequently
    # appear together in classes and parameter lists, or when a group
    # of instance variable names start or end with similar substrings.
    #
    # The recurrence of the items often means there is duplicate code
    # spread around to handle them. There may be an abstraction missing
    # from the code, making the system harder to understand.
    #
    # Currently Reek looks for a group of two or more parameters with
    # the same names that are expected by three or more methods of a class.
    #
    class DataClump < SmellDetector

      def self.contexts      # :nodoc:
        [:class]
      end

      # The name of the config field that sets the maximum allowed
      # copies of any clump.
      MAX_COPIES_KEY = 'max_copies'

      DEFAULT_MAX_COPIES = 2

      MIN_CLUMP_SIZE_KEY = 'min_clump_size'
      DEFAULT_MIN_CLUMP_SIZE = 2

      def self.default_config
        super.adopt(
          MAX_COPIES_KEY => DEFAULT_MAX_COPIES,
          MIN_CLUMP_SIZE_KEY => DEFAULT_MIN_CLUMP_SIZE
        )
      end

      def initialize(config = DataClump.default_config)
        super(config)
      end

      #
      # Checks the given ClassContext for multiple identical conditional tests.
      # Remembers any smells found.
      #
      def examine_context(klass)
        max_copies = value(MAX_COPIES_KEY, klass, DEFAULT_MAX_COPIES)
        min_clump_size = value(MIN_CLUMP_SIZE_KEY, klass, DEFAULT_MIN_CLUMP_SIZE)
        MethodGroup.new(klass, min_clump_size, max_copies).clumps.each {|clump, occurs|
          found(klass, "takes parameters #{DataClump.print_clump(clump)} to #{occurs} methods")
        }
      end

      def self.print_clump(clump)
        "[#{clump.map {|name| name.to_s}.join(', ')}]"
      end
    end
  end

  # Represents a group of methods
  class MethodGroup

    def self.intersection_of_parameters_of(methods)
      methods.map {|meth| meth.parameters.names.sort}.intersection
    end

    def initialize(klass, min_clump_size, max_copies)
      @klass = klass
      @min_clump_size = min_clump_size
      @max_copies = max_copies
    end

    def clumps
      results = Hash.new(0)
      @klass.parameterized_methods(@min_clump_size).bounded_power_set(@max_copies).each {|methods|
        clump = MethodGroup.intersection_of_parameters_of(methods)
        if clump.length >= @min_clump_size
          results[clump] = [methods.length, results[clump]].max
        end
      }
      results
    end
  end
end
