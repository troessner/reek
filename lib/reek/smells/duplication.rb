require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    #
    # Duplication occurs when two fragments of code look nearly identical,
    # or when two fragments of code have nearly identical effects
    # at some conceptual level.
    # 
    # Currently +Duplication+ checks for repeated identical method calls
    # within any one method definition. For example, the following method
    # will report a warning:
    # 
    #   def double_thing()
    #     @other.thing + @other.thing
    #   end
    #
    class Duplication < SmellDetector

      # The name of the config field that sets the maximum number of
      # identical calls to be permitted within any single method.
      MAX_ALLOWED_CALLS_KEY = 'max_calls'

      DEFAULT_MAX_CALLS = 1

      def self.default_config
        super.adopt(MAX_ALLOWED_CALLS_KEY => DEFAULT_MAX_CALLS)
      end

      def initialize(source, config = Duplication.default_config)
        super(source, config)
      end

      def examine_context(method_ctx)
        calls(method_ctx).each do |call_exp, copies|
          occurs = copies.length
          next if occurs <= value(MAX_ALLOWED_CALLS_KEY, method_ctx, DEFAULT_MAX_CALLS)
          call = call_exp.format
          multiple = occurs == 2 ? 'twice' : "#{occurs} times"
          found(method_ctx, "calls #{call} #{multiple}",
            'DuplicateMethodCall', {'call' => call, 'occurrences' => occurs},
            copies.map {|exp| exp.line})
        end
      end

      def calls(method_ctx)
        result = Hash.new {|hash,key| hash[key] = []}
        method_ctx.local_nodes(:call) do |call_node|
          next if call_node.method_name == :new
          result[call_node].push(call_node)
        end
        method_ctx.local_nodes(:attrasgn) do |asgn_node|
          result[asgn_node].push(asgn_node) unless asgn_node.args.length < 2
        end
        result
      end
    end
  end
end
