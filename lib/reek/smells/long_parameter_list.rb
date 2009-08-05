require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A Long Parameter List occurs when a method has more than one
    # or two parameters, or when a method yields more than one or
    # two objects to an associated block.
    #
    # Currently +LongParameterList+ reports any method or block with too
    # many parameters.
    #
    class LongParameterList < SmellDetector

      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'

      def self.default_config
        super.adopt(
          MAX_ALLOWED_PARAMS_KEY => 3,
          "exceptions" => {
            "initialize" => {MAX_ALLOWED_PARAMS_KEY => 5}
            }
        )
      end

      def initialize(config = LongParameterList.default_config)
        super(config)
        @action = 'has'
      end

      def value(key, ctx)
        if @config.has_key?('exceptions')
          exc = @config['exceptions'].select {|hk,hv| ctx.matches?(hk)}
          if exc.length > 0
            conf = exc[0][1]
            if conf.has_key?(key)
              return conf[key]
            end
          end
        end
        return @config[key]
      end

      #
      # Checks the number of parameters in the given scope.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        num_params = ctx.parameters.length
        return false if num_params <= value(MAX_ALLOWED_PARAMS_KEY, ctx)
        found(ctx, "#{@action} #{num_params} parameters")
      end
    end
  end
end
