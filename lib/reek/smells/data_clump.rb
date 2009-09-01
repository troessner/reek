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
        method_sets = candidate_methods(klass, min_clump_size).power_set.select {|ps| ps.length > max_copies}
        results = Hash.new(0)
        method_sets.each {|set|
          params_set = set.map {|meth| meth.parameters.names.sort}
          clump = params_set.inject { |res, elem| elem & res }
          if clump.length >= min_clump_size
            results[clump] = [set.length, results[clump]].max
          end
        }
        results.each {|clump, occurs|
          found(klass, "takes parameters [#{clump.map{|nm| nm.to_s}.join(', ')}] to #{occurs} methods")
        }
      end

      def candidate_methods(klass, min_clump_size)
        klass.parsed_methods.select {|meth| meth.parameters.length >= min_clump_size }
      end
    end
  end
end
