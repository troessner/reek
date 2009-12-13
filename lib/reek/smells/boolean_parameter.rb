require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A Boolean parameter effectively permits a method's caller
    # to decide which execution path to take. The
    # offending parameter is a kind of Control Couple.
    # 
    # Currently Reek can only detect a Boolean parameter when it has a
    # default initializer.
    #
    class BooleanParameter < SmellDetector

      def self.contexts      # :nodoc:
        [:defn, :defs]
      end

      #
      # Checks whether the given method has a Boolean parameter.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        ctx.parameters.default_assignments.each do |param, value|
          next unless [:true, :false].include?(value[0])
          found(ctx, "has boolean parameter #{param.to_s}", '', [param.to_s])
        end
      end
    end
  end
end
