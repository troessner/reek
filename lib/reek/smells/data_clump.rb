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
        [:class, :module]
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

      def initialize(source = '???', config = DataClump.default_config)
        super(source, config)
      end

      #
      # Checks the given class or module for multiple identical parameter sets.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        max_copies = value(MAX_COPIES_KEY, ctx, DEFAULT_MAX_COPIES)
        min_clump_size = value(MIN_CLUMP_SIZE_KEY, ctx, DEFAULT_MIN_CLUMP_SIZE)
        MethodGroup.new(ctx, min_clump_size, max_copies).clumps.each do |clump, occurs|
          found(ctx, "takes parameters #{DataClump.print_clump(clump)} to #{occurs} methods",
            'DataClump', {'parameters' => clump.map {|name| name.to_s}, 'occurrences' => occurs})
          # SMELL: name.to_s is becoming a nuisance
          # TODO: record the methods in [lines] and in the hash
        end
      end

      def self.print_clump(clump)
        "[#{clump.map {|name| name.to_s}.join(', ')}]"
      end
    end
  end

  # Represents a group of methods
  class MethodGroup   # :nodoc:

    def self.intersection_of_parameters_of(methods)
      methods.map {|meth| meth.parameters.names.sort}.intersection
    end

    def initialize(ctx, min_clump_size, max_copies)
      @ctx = ctx
      @min_clump_size = min_clump_size
      @max_copies = max_copies
    end

    def clumps
      results = Hash.new(0)
      @ctx.parameterized_methods(@min_clump_size).bounded_power_set(@max_copies).each do |methods|
        clump = MethodGroup.intersection_of_parameters_of(methods)
        if clump.length >= @min_clump_size
          results[clump] = [methods.length, results[clump]].max
        end
      end
      results
    end
  end
end
