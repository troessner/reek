require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # a module is usually a mixin, so when initialize method is present it is
    # hard to tell initialization order and parameters so having 'initialize'
    # in a module is usually a bad idea
    #
    # See {file:docs/Module-Initialize.md} for details.
    class ModuleInitialize < SmellDetector
      def self.contexts # :nodoc:
        [:module]
      end

      #
      # Checks whether module has method 'initialize'.
      #
      # @return [Array<SmellWarning>]
      #
      # :reek:FeatureEnvy
      def inspect(ctx)
        ctx.local_nodes(:def) do |node| # FIXME: also search for :defs?
          if node.name.to_s == 'initialize'
            return [
              smell_warning(
                context: ctx,
                lines:   [ctx.exp.line],
                message: 'has initialize method')
            ]
          end
        end
        []
      end
    end
  end
end
