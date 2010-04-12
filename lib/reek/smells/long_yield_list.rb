require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    #
    # A variant on LongParameterList that checks the number of items
    # passed to a block by a +yield+ call.
    #
    class LongYieldList < SmellDetector

      SMELL_SUBCLASS = self.name.split(/::/)[-1]
      SMELL_CLASS = 'LongParameterList'

      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'

      # The default value of the +MAX_ALLOWED_PARAMS_KEY+ configuration
      # value.
      DEFAULT_MAX_ALLOWED_PARAMS = 3

      PARAMETER_COUNT_KEY = 'parameter_count'

      def self.default_config
        super.adopt(
          MAX_ALLOWED_PARAMS_KEY => DEFAULT_MAX_ALLOWED_PARAMS
        )
      end

      def initialize(source, config = LongYieldList.default_config)
        super(source, config)
      end

      #
      # Checks the number of parameters in the given scope.
      # Remembers any smells found.
      #
      def examine_context(method_ctx)
        method_ctx.local_nodes(:yield).each do |yield_node|
          num_params = yield_node.args.length
          next if num_params <= value(MAX_ALLOWED_PARAMS_KEY, method_ctx, DEFAULT_MAX_ALLOWED_PARAMS)
          smell = SmellWarning.new(SMELL_CLASS, method_ctx.full_name, [yield_node.line],
            "yields #{num_params} parameters",
            @source, SMELL_SUBCLASS, {PARAMETER_COUNT_KEY => num_params})
          @smells_found << smell
          #SMELL: serious duplication
        end
      end
    end
  end
end
