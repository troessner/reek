# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

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
    # See {file:docs/Uncommunicative-Variable-Name.md} for details.
    #
    # :reek:DataClump: { max_copies: 4 }
    class UncommunicativeVariableName < SmellDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'.freeze
      DEFAULT_REJECT_SET = [/^.$/, /[0-9]$/, /[A-Z]/].freeze

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'.freeze
      DEFAULT_ACCEPT_SET = ['_'].freeze

      def self.default_config
        super.merge(
          REJECT_KEY => DEFAULT_REJECT_SET,
          ACCEPT_KEY => DEFAULT_ACCEPT_SET)
      end

      def self.contexts
        [:module, :class, :def, :defs]
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        self.reject_names = value(REJECT_KEY, ctx)
        self.accept_names = value(ACCEPT_KEY, ctx)
        variable_names(ctx.exp).select do |name, _lines|
          bad_name?(name, ctx)
        end.map do |name, lines|
          smell_warning(
            context: ctx,
            lines: lines,
            message: "has the variable name '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      def bad_name?(name, _ctx)
        var = name.to_s.gsub(/^[@\*\&]*/, '')
        return false if accept_names.include?(var)
        reject_names.find { |patt| patt =~ var }
      end

      # :reek:TooManyStatements: { max_statements: 6 }
      def variable_names(exp)
        result = Hash.new { |hash, key| hash[key] = [] }
        find_assignment_variable_names(exp, result)
        find_block_argument_variable_names(exp, result)
        result.to_a.sort_by { |name, _| name.to_s }
      end

      # :reek:UtilityFunction
      def find_assignment_variable_names(exp, accumulator)
        assignment_nodes = exp.each_node(:lvasgn, [:class, :module, :defs, :def])

        case exp.type
        when :class, :module
          assignment_nodes += exp.each_node(:ivasgn, [:class, :module])
        end

        assignment_nodes.each { |asgn| accumulator[asgn.children.first].push(asgn.line) }
      end

      # :reek:FeatureEnvy
      # :reek:TooManyStatements: { max_statements: 6 }
      def find_block_argument_variable_names(exp, accumulator)
        arg_search_exp = case exp.type
                         when :class, :module
                           exp
                         when :defs, :def
                           exp.body
                         end

        return unless arg_search_exp
        args_nodes = arg_search_exp.each_node(:args, [:class, :module, :defs, :def])

        args_nodes.each do |args_node|
          recursively_record_variable_names(accumulator, args_node)
        end
      end

      def recursively_record_variable_names(accumulator, exp)
        exp.children.each do |subexp|
          case subexp.type
          when :mlhs
            recursively_record_variable_names(accumulator, subexp)
          else
            record_variable_name(exp, subexp.name, accumulator)
          end
        end
      end

      # :reek:UtilityFunction
      def record_variable_name(exp, symbol, accumulator)
        varname = symbol.to_s.sub(/^\*/, '')
        return if varname == ''
        var = varname.to_sym
        accumulator[var].push(exp.line)
      end

      private

      attr_accessor :accept_names, :reject_names
    end
  end
end
