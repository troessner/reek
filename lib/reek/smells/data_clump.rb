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
    # Currently Reek looks for a group of three or more parameters with
    # the same names that are expected by three or more methods of a class.
    #
    class DataClump < SmellDetector

      def self.contexts      # :nodoc:
        [:class]
      end

      # The name of the config field that sets the maximum allowed
      # copies of any clump.
      MAX_CLUMPS_KEY = 'max_clumps'

      DEFAULT_MAX_CLUMPS = 2

      MIN_CLUMP_SIZE_KEY = 'min_clump_size'
      DEFAULT_MIN_CLUMP_SIZE = 2

      def self.default_config
        super.adopt(
          MAX_CLUMPS_KEY => DEFAULT_MAX_CLUMPS,
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
        parameter_sets = candidate_param_sets(klass)
        power_sets = parameter_sets.map {|params| power_set(params, klass)}
        counts = Hash.new(0)
        power_sets.each do |power_set|
          power_set.each {|set| counts[set] += 1}
        end
        counts.each_key do |key|
          if counts[key] >= value(MIN_CLUMP_SIZE_KEY, klass, DEFAULT_MIN_CLUMP_SIZE)
            found(klass, "takes parameters [#{key.map{|nm| nm.to_s}.join(', ')}] to #{counts[key]} methods")
            # SMELL: same array formatting as in MethodParameters
          end
        end
      end

      def candidate_param_sets(klass)
        klass.parsed_methods.map {|meth| meth.parameters}.select do |params|
          params.length >= value(MIN_CLUMP_SIZE_KEY, klass, DEFAULT_MIN_CLUMP_SIZE)
        end
      end

      def power_set(params, klass)
        params.power_set.select {|set| set.length >= value(MIN_CLUMP_SIZE_KEY, klass, DEFAULT_MIN_CLUMP_SIZE)}
      end
    end
  end
end
