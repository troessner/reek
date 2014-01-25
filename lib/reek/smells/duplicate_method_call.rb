require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

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
    class DuplicateMethodCall < SmellDetector
      SMELL_CLASS = 'Duplication'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      CALL_KEY = 'call'
      OCCURRENCES_KEY = 'occurrences'

      # The name of the config field that sets the maximum number of
      # identical calls to be permitted within any single method.
      MAX_ALLOWED_CALLS_KEY = 'max_calls'

      DEFAULT_MAX_CALLS = 1

      # The name of the config field that sets the names of any
      # methods for which identical calls should be to be permitted
      # within any single method.
      ALLOW_CALLS_KEY = 'allow_calls'

      DEFAULT_ALLOW_CALLS = []

      def self.default_config
        super.merge(
          MAX_ALLOWED_CALLS_KEY => DEFAULT_MAX_CALLS,
          ALLOW_CALLS_KEY => DEFAULT_ALLOW_CALLS
        )
      end

      #
      # Looks for duplicate calls within the body of the method +ctx+.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        max_allowed_calls = value(MAX_ALLOWED_CALLS_KEY, ctx, DEFAULT_MAX_CALLS)
        allow_calls = value(ALLOW_CALLS_KEY, ctx, DEFAULT_ALLOW_CALLS)

        CallCollector.new(ctx, max_allowed_calls, allow_calls).smelly_calls.map do |found_call|
          SmellWarning.new(SMELL_CLASS, ctx.full_name, found_call.lines,
                           found_call.smell_message,
                           @source, SMELL_SUBCLASS,
                           {CALL_KEY => found_call.call, OCCURRENCES_KEY => found_call.occurs})
        end
      end

      # Collects information about a single found call
      class FoundCall
        def initialize(call_node)
          @call_node = call_node
          @occurences = []
        end

        def record(occurence)
          @occurences.push occurence
        end

        def smell_message
          multiple = occurs == 2 ? 'twice' : "#{occurs} times"
          "calls #{call} #{multiple}"
        end

        def call
          @call ||= @call_node.format_ruby
        end

        def occurs
          @occurences.length
        end

        def lines
          @occurences.map {|exp| exp.line}
        end
      end

      # Collects all calls in a given context
      class CallCollector
        attr_reader :context

        def initialize(context, max_allowed_calls, allow_calls)
          @context = context
          @max_allowed_calls = max_allowed_calls
          @allow_calls = allow_calls
        end

        def calls
          result = Hash.new {|hash,key| hash[key] = FoundCall.new(key)}
          collect_calls(result)
          collect_assignments(result)
          result.values.sort_by {|found_call| found_call.call}
        end

        def smelly_calls
          calls.select {|found_call| smelly_call? found_call }
        end

        private

        def collect_assignments(result)
          context.local_nodes(:attrasgn) do |asgn_node|
            result[asgn_node].record(asgn_node) if asgn_node.args
          end
        end

        def collect_calls(result)
          context.local_nodes(:call) do |call_node|
            next if call_node.method_name == :new
            next if !call_node.receiver && call_node.args.empty?
            result[call_node].record(call_node)
          end
        end

        def smelly_call?(found_call)
          found_call.occurs > @max_allowed_calls and not allow_calls?(found_call.call)
        end

        def allow_calls?(method)
          @allow_calls.any? { |allow| /#{allow}/ === method }
        end
      end
    end
  end
end
