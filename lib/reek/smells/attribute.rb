require_relative 'smell_configuration'
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # A class that publishes a getter or setter for an instance variable
    # invites client classes to become too intimate with its inner workings,
    # and in particular with its representation of state.
    #
    # This detector raises a warning for every public +attr_writer+,
    # +attr_accessor+, and +attr+ with the writable flag set to +true+.
    #
    # See {file:docs/Attribute.md} for details.
    #
    # TODO: Catch attributes declared "by hand"
    class Attribute < SmellDetector
      def initialize(*args)
        super
      end

      def self.contexts # :nodoc:
        [:sym]
      end

      #
      # Checks whether the given class declares any attributes.
      #
      # @return [Array<SmellWarning>]
      #
      def inspect(ctx)
        attributes_in(ctx).map do |attribute, line|
          smell_warning(
            context: ctx,
            lines: [line],
            message: 'is a writable attribute',
            parameters: { name: attribute.to_s })
        end
      end

      private

      # :reek:UtilityFunction
      def attributes_in(module_ctx)
        if module_ctx.visibility == :public
          call_node = module_ctx.exp
          [[call_node.name, call_node.line]]
        else
          []
        end
      end
    end
  end
end
