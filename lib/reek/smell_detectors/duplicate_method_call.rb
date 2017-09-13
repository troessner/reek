# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # Duplication occurs when two fragments of code look nearly identical,
    # or when two fragments of code have nearly identical effects
    # at some conceptual level.
    #
    # +DuplicateMethodCall+ checks for repeated identical method calls
    # within any one method definition. For example, the following method
    # will report a warning:
    #
    #   def double_thing()
    #     @other.thing + @other.thing
    #   end
    #
    # See {file:docs/Duplicate-Method-Call.md} for details.
    class DuplicateMethodCall < BaseDetector
      # The name of the config field that sets the maximum number of
      # identical calls to be permitted within any single method.
      MAX_ALLOWED_CALLS_KEY = 'max_calls'.freeze
      DEFAULT_MAX_CALLS = 1

      # The name of the config field that sets the names of any
      # methods for which identical calls should be to be permitted
      # within any single method.
      ALLOW_CALLS_KEY = 'allow_calls'.freeze
      DEFAULT_ALLOW_CALLS = [].freeze

      def self.default_config
        super.merge(
          MAX_ALLOWED_CALLS_KEY => DEFAULT_MAX_CALLS,
          ALLOW_CALLS_KEY => DEFAULT_ALLOW_CALLS)
      end

      #
      # Looks for duplicate calls within the body of the method context.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        collector = CallCollector.new(context, max_allowed_calls, allow_calls)
        collector.smelly_calls.map do |found_call|
          call = found_call.call
          occurs = found_call.occurs
          smell_warning(
            context: context,
            lines: found_call.lines,
            message: "calls '#{call}' #{occurs} times",
            parameters: { name: call, count: occurs })
        end
      end

      private

      def max_allowed_calls
        value(MAX_ALLOWED_CALLS_KEY, context)
      end

      def allow_calls
        value(ALLOW_CALLS_KEY, context)
      end

      # Collects information about a single found call
      class FoundCall
        def initialize(call_node)
          @call_node = call_node
          @occurences = []
        end

        def record(occurence)
          occurences.push occurence
        end

        def call
          @call ||= call_node.format_to_ruby
        end

        def occurs
          occurences.length
        end

        def lines
          occurences.map(&:line)
        end

        private

        attr_reader :call_node, :occurences
      end

      private_constant :FoundCall

      # Collects all calls in a given context
      class CallCollector
        attr_reader :context

        def initialize(context, max_allowed_calls, allow_calls)
          @context = context
          @max_allowed_calls = max_allowed_calls
          @allow_calls = allow_calls
        end

        def calls
          result = Hash.new { |hash, key| hash[key] = FoundCall.new(key) }
          collect_calls(result)
          result.values.sort_by(&:call)
        end

        def smelly_calls
          calls.select { |found_call| smelly_call? found_call }
        end

        private

        attr_reader :allow_calls, :max_allowed_calls

        # :reek:TooManyStatements: { max_statements: 6 }
        # :reek:DuplicateMethodCall: { max_calls: 2 }
        def collect_calls(result)
          context.each_node(:send, [:mlhs]) do |call_node|
            next if call_node.object_creation_call?
            next if simple_method_call? call_node
            result[call_node].record(call_node)
          end
          context.local_nodes(:block) do |call_node|
            result[call_node].record(call_node)
          end
        end

        def smelly_call?(found_call)
          found_call.occurs > max_allowed_calls && !allow_calls?(found_call.call)
        end

        # :reek:UtilityFunction
        def simple_method_call?(call_node)
          !call_node.receiver && call_node.args.empty?
        end

        def allow_calls?(method)
          allow_calls.any? { |allow| /#{allow}/ =~ method }
        end
      end

      private_constant :CallCollector
    end
  end
end
