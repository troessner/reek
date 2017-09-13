# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # An Uncommunicative Name is a name that doesn't communicate its intent
    # well enough.
    #
    # Poor names make it hard for the reader to build a mental picture
    # of what's going on in the code. They can also be mis-interpreted;
    # and they hurt the flow of reading, because the reader must slow
    # down to interpret the names.
    #
    # Currently +UncommunicativeName+ checks for:
    #
    # * single-character names
    # * any name ending with a number
    # * camelCaseVariableNames
    #
    # See {file:docs/Uncommunicative-Variable-Name.md} for details.
    #
    class UncommunicativeVariableName < BaseDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'.freeze
      DEFAULT_REJECT_SET = [
        /^.$/, # single-character names
        /[0-9]$/,  # any name ending with a number
        /[A-Z]/    # camelCaseVariableNames
      ].freeze

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'.freeze
      DEFAULT_ACCEPT_SET = [/^_$/].freeze

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
      def sniff
        variable_names.select do |name, _lines|
          uncommunicative_variable_name?(name)
        end.map do |name, lines|
          smell_warning(
            context: context,
            lines: lines,
            message: "has the variable name '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      private

      def reject_names
        @reject_names ||= value(REJECT_KEY, context)
      end

      def accept_names
        @accept_names ||= value(ACCEPT_KEY, context)
      end

      def uncommunicative_variable_name?(name)
        sanitized_name = name.to_s.gsub(/^[@\*\&]*/, '')
        !acceptable_name?(sanitized_name)
      end

      def acceptable_name?(name)
        Array(accept_names).any? { |accept_pattern| name.match accept_pattern } ||
          Array(reject_names).none? { |reject_pattern| name.match reject_pattern }
      end

      def variable_names
        result = Hash.new { |hash, key| hash[key] = [] }
        find_assignment_variable_names(result)
        find_block_argument_variable_names(result)
        result
      end

      def find_assignment_variable_names(accumulator)
        assignment_nodes = expression.each_node(:lvasgn, [:class, :module, :defs, :def])

        case expression.type
        when :class, :module
          assignment_nodes += expression.each_node(:ivasgn, [:class, :module])
        end

        assignment_nodes.each { |asgn| accumulator[asgn.children.first].push(asgn.line) }
      end

      # :reek:TooManyStatements: { max_statements: 6 }
      def find_block_argument_variable_names(accumulator)
        arg_search_exp = case expression.type
                         when :class, :module
                           expression
                         when :defs, :def
                           expression.body
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
    end
  end
end
