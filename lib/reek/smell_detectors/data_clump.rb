# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
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
    # See {file:docs/Data-Clump.md} for details.
    class DataClump < BaseDetector
      #
      # The name of the config field that sets the maximum allowed
      # copies of any clump. No group of common parameters will be
      # reported as a DataClump unless there are more than this many
      # methods containing those parameters.
      #
      MAX_COPIES_KEY = 'max_copies'.freeze
      DEFAULT_MAX_COPIES = 2

      #
      # The name of the config field that sets the minimum clump
      # size. No group of common parameters will be reported as
      # a DataClump unless it contains at least this many parameters.
      #
      MIN_CLUMP_SIZE_KEY = 'min_clump_size'.freeze
      DEFAULT_MIN_CLUMP_SIZE = 2

      def self.contexts # :nodoc:
        [:class, :module]
      end

      def self.default_config
        super.merge(
          MAX_COPIES_KEY => DEFAULT_MAX_COPIES,
          MIN_CLUMP_SIZE_KEY => DEFAULT_MIN_CLUMP_SIZE)
      end

      #
      # Checks the given class or module for multiple identical parameter sets.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        MethodGroup.new(context, min_clump_size, max_copies).clumps.map do |clump, methods|
          methods_length = methods.length
          smell_warning(
            context: context,
            lines: methods.map(&:line),
            message: "takes parameters #{DataClump.print_clump(clump)} " \
                     "to #{methods_length} methods",
            parameters: {
              parameters: clump.map(&:to_s),
              count: methods_length
            })
        end
      end

      # @private
      def self.print_clump(clump)
        "[#{clump.map { |parameter| "'#{parameter}'" }.join(', ')}]"
      end

      private

      def max_copies
        value(MAX_COPIES_KEY, context)
      end

      def min_clump_size
        value(MIN_CLUMP_SIZE_KEY, context)
      end
    end
  end

  # Represents a group of methods
  # @private
  class MethodGroup
    def initialize(ctx, min_clump_size, max_copies)
      @min_clump_size = min_clump_size
      @max_copies = max_copies
      @candidate_methods = ctx.node_instance_methods.map do |defn_node|
        CandidateMethod.new(defn_node)
      end
    end

    def candidate_clumps
      candidate_methods.each_cons(max_copies + 1).map do |methods|
        common_argument_names_for(methods)
      end.select do |clump|
        clump.length >= min_clump_size
      end.uniq
    end

    # :reek:UtilityFunction
    def common_argument_names_for(methods)
      methods.map(&:arg_names).inject(:&)
    end

    def methods_containing_clump(clump)
      candidate_methods.select { |method| clump & method.arg_names == clump }
    end

    def clumps
      candidate_clumps.map do |clump|
        [clump, methods_containing_clump(clump)]
      end
    end

    private

    attr_reader :candidate_methods, :max_copies, :min_clump_size
  end

  # A method definition and a copy of its parameters
  # @private
  class CandidateMethod
    extend Forwardable

    def_delegators :defn, :line, :name

    def initialize(defn_node)
      @defn = defn_node
    end

    def arg_names
      # TODO: Is all this sorting still needed?
      @arg_names ||= defn.arg_names.compact.sort
    end

    private

    attr_reader :defn
  end
end
