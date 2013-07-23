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
        super.adopt(
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
        @max_allowed_calls = value(MAX_ALLOWED_CALLS_KEY, ctx, DEFAULT_MAX_CALLS)
        @allow_calls = value(ALLOW_CALLS_KEY, ctx, DEFAULT_ALLOW_CALLS)
        calls(ctx).select do |call_exp, copies|
          copies.length > @max_allowed_calls and not allow_calls?(call_exp.format_ruby)
        end.map do |call_exp, copies|
          occurs = copies.length
          call = call_exp.format_ruby
          multiple = occurs == 2 ? 'twice' : "#{occurs} times"
          smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, copies.map {|exp| exp.line},
            "calls #{call} #{multiple}",
            @source, SMELL_SUBCLASS,
            {CALL_KEY => call, OCCURRENCES_KEY => occurs})
          smell
        end
      end

    private

      def calls(method_ctx)
        result = Hash.new {|hash,key| hash[key] = []}
        method_ctx.local_nodes(:call) do |call_node|
          next if call_node.method_name == :new
          next if call_node.receiver.nil? && call_node.args.empty?
          result[call_node].push(call_node)
        end
        method_ctx.local_nodes(:attrasgn) do |asgn_node|
          result[asgn_node].push(asgn_node) unless asgn_node.args.nil?
        end
        result.to_a.sort_by {|call_exp, _| call_exp.format_ruby}
      end

      def allow_calls?(method)
        @allow_calls.any? { |allow| /#{allow}/ === method }
      end
    end
  end
end
