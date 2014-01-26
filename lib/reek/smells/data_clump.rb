require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/source'

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

      SMELL_CLASS = self.name.split(/::/)[-1]
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      METHODS_KEY = 'methods'
      OCCURRENCES_KEY = 'occurrences'
      PARAMETERS_KEY = 'parameters'

      # @private
      def self.contexts
        [:class, :module]
      end

      #
      # The name of the config field that sets the maximum allowed
      # copies of any clump. No group of common parameters will be
      # reported as a DataClump unless there are more than this many
      # methods containing those parameters.
      #
      MAX_COPIES_KEY = 'max_copies'
      DEFAULT_MAX_COPIES = 2

      #
      # The name of the config field that sets the minimum clump
      # size. No group of common parameters will be reported as
      # a DataClump unless it contains at least this many parameters.
      #
      MIN_CLUMP_SIZE_KEY = 'min_clump_size'
      DEFAULT_MIN_CLUMP_SIZE = 2

      def self.default_config
        super.merge(
          MAX_COPIES_KEY => DEFAULT_MAX_COPIES,
          MIN_CLUMP_SIZE_KEY => DEFAULT_MIN_CLUMP_SIZE
        )
      end

      #
      # Checks the given class or module for multiple identical parameter sets.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @max_copies = value(MAX_COPIES_KEY, ctx, DEFAULT_MAX_COPIES)
        @min_clump_size = value(MIN_CLUMP_SIZE_KEY, ctx, DEFAULT_MIN_CLUMP_SIZE)
        MethodGroup.new(ctx, @min_clump_size, @max_copies).clumps.map do |clump, methods|
          SmellWarning.new(SMELL_CLASS, ctx.full_name,
                           methods.map {|meth| meth.line},
                           "takes parameters #{DataClump.print_clump(clump)} to #{methods.length} methods",
                           @source, SMELL_SUBCLASS, {
                             PARAMETERS_KEY => clump.map {|name| name.to_s},
                             OCCURRENCES_KEY => methods.length,
                             METHODS_KEY => methods.map {|meth| meth.name}
                           })
        end
      end

      # @private
      def self.print_clump(clump)
        "[#{clump.map {|name| name.to_s}.join(', ')}]"
      end
    end
  end

  # Represents a group of methods
  # @private
  class MethodGroup

    def initialize(ctx, min_clump_size, max_copies)
      @min_clump_size = min_clump_size
      @max_copies = max_copies
      @candidate_methods = ctx.local_nodes(:defn).map {|defn_node|
        CandidateMethod.new(defn_node)}
    end

    def candidate_clumps
      @candidate_methods.each_cons(@max_copies + 1).map do |methods|
        common_argument_names_for(methods)
      end.select do |clump|
        clump.length >= @min_clump_size
      end.uniq
    end

    def common_argument_names_for(methods)
      methods.collect(&:arg_names).inject(:&)
    end

    def methods_containing_clump(clump)
      @candidate_methods.select { |method| clump & method.arg_names == clump }
    end

    def clumps
      candidate_clumps.map do |clump|
        [clump, methods_containing_clump(clump)]
      end
    end
  end

  # A method definition and a copy of its parameters
  # @private
  class CandidateMethod
    def initialize(defn_node)
      @defn = defn_node
      @params = defn_node.arg_names.clone.sort {|first, second| first.to_s <=> second.to_s}
    end

    def arg_names
      @params
    end

    def line
      @defn.line
    end

    def name
      @defn.name.to_s     # BUG: should report the symbols!
    end
  end
end
