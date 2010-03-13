require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'source')

#
# Extensions to +Array+ needed by Reek.
#
class Array
  def power_set
    self.inject([[]]) { |cum, element| cum.cross(element) }
  end

  def bounded_power_set(lower_bound)
    power_set.select {|ps| ps.length > lower_bound}
  end

  def cross(element)
    result = []
    self.each do |set|
      result << set
      result << (set + [element])
    end
    result
  end

  def intersection
    self.inject { |res, elem| elem & res }
  end
end

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

      METHODS_KEY = 'methods'
      OCCURRENCES_KEY = 'occurrences'
      PARAMETERS_KEY = 'parameters'

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

      def initialize(source, config = DataClump.default_config)
        super(source, config)
      end

      #
      # Checks the given class or module for multiple identical parameter sets.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        max_copies = value(MAX_COPIES_KEY, ctx, DEFAULT_MAX_COPIES)
        min_clump_size = value(MIN_CLUMP_SIZE_KEY, ctx, DEFAULT_MIN_CLUMP_SIZE)
        MethodGroup.new(ctx, min_clump_size, max_copies).clumps.each do |clump, methods|
          smell = SmellWarning.new('DataClump', ctx.full_name,
            methods.map {|meth| meth.line},
            "takes parameters #{DataClump.print_clump(clump)} to #{methods.length} methods",
            @source, 'DataClump', {
              PARAMETERS_KEY => clump.map {|name| name.to_s},
              OCCURRENCES_KEY => methods.length,
              METHODS_KEY => methods.map {|meth| meth.name}
            })
          @smells_found << smell
          #SMELL: serious duplication
          # SMELL: name.to_s is becoming a nuisance
        end
      end

      def self.print_clump(clump)
        "[#{clump.map {|name| name.to_s}.join(', ')}]"
      end
    end
  end

  # Represents a group of methods
  # @private
  class MethodGroup   # :nodoc:

    def self.intersection_of_parameters_of(methods)
      methods.map {|meth| meth.arg_names.sort {|a,b| a.to_s <=> b.to_s}}.intersection
    end

    def initialize(ctx, min_clump_size, max_copies)
      @min_clump_size = min_clump_size
      @max_copies = max_copies
      @candidate_methods = ctx.local_nodes(:defn).select do |meth|
        meth.arg_names.length >= @min_clump_size
      end.map {|defn_node| CandidateMethod.new(defn_node)}
      prune_candidates
    end

    def clumps
      results = Hash.new([])
      @candidate_methods.bounded_power_set(@max_copies).each do |methods|
        clump = MethodGroup.intersection_of_parameters_of(methods)
        if clump.length >= @min_clump_size
          results[clump] = methods if methods.length > results[clump].length
        end
      end
      results
    end

    def prune_candidates
      @candidate_methods.each do |meth|
        meth.arg_names.each do |param|
          count = @candidate_methods.select {|cm| cm.arg_names.include?(param)}.length
          meth.delete(param) if count <= @max_copies
        end
      end
      @candidate_methods = @candidate_methods.select do |meth|
        meth.arg_names.length >= @min_clump_size
      end
    end
  end

  class CandidateMethod
    def initialize(defn_node)
      @defn = defn_node
      @params = defn_node.arg_names.clone
    end

    def arg_names
      @params
    end

    def delete(param)
      @params.delete(param)
    end

    def line
      @defn.line
    end

    def name
      @defn.name.to_s     # BUG: should report the symbols!
    end
  end
end
