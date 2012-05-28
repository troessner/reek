require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    #
    # An Uncommunicative Name is a name that doesn't communicate its intent
    # well enough.
    # 
    # Poor names make it hard for the reader to build a mental picture
    # of what's going on in the code. They can also be mis-interpreted;
    # and they hurt the flow of reading, because the reader must slow
    # down to interpret the names.
    #
    # Currently +UncommunicativeName+ checks for
    # * 1-character names
    # * names ending with a number
    #
    # 
    #
    class UncommunicativeVariableName < SmellDetector

      SMELL_CLASS = 'UncommunicativeName'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]
      VARIABLE_NAME_KEY = 'variable_name'

      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'

      DEFAULT_REJECT_SET = [/^.$/, /[0-9]$/, /[A-Z]/]

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ALLOW_KEY = 'allow'

      DEFAULT_ALLOW_SET = ['_']

      def self.default_config
        super.adopt(
                REJECT_KEY => DEFAULT_REJECT_SET,
                ALLOW_KEY => DEFAULT_ALLOW_SET
        )
      end

      def self.contexts      # :nodoc:
        [:module, :class, :defn, :defs]
      end

      def initialize(source, config = UncommunicativeVariableName.default_config)
        super(source, config)
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @reject_names = value(REJECT_KEY, ctx, DEFAULT_REJECT_SET)
        @allow_names = value(ALLOW_KEY, ctx, DEFAULT_ALLOW_SET)
        variable_names(ctx.exp).select do |name, lines|
          is_bad_name?(name, ctx)
        end.map do |name, lines|
          SmellWarning.new(SMELL_CLASS, ctx.full_name, lines,
                           "has the variable name '#{name}'",
                           @source, SMELL_SUBCLASS, {VARIABLE_NAME_KEY => name.to_s})
        end
      end

      def is_bad_name?(name, ctx)
        var = name.to_s.gsub(/^[@\*\&]*/, '')
        return false if @allow_names.include?(var)
        @reject_names.detect {|patt| patt === var}
      end

      def variable_names(exp)
        assignment_nodes = exp.each_node(:lasgn, [:class, :module, :defs, :defn])
        case exp.first
          when :class, :module
            assignment_nodes += exp.each_node(:iasgn, [:class, :module])
        end
        result = Hash.new {|hash, key| hash[key] = []}
        assignment_nodes.each {|asgn| result[asgn[1]].push(asgn.line) }
        result
      end
    end
  end
end
