require_relative 'smell_detector'

module Reek
  module Smells
    #
    # a module is usually a mixin, so when initialize method is present it is
    # hard to tell initialization order and parameters so having 'initialize'
    # in a module is usually a bad idea
    #
    # See docs/Module-Initialize for details.
    class ModuleInitialize < SmellDetector
      def self.contexts # :nodoc:
        [:module]
      end

      #
      # Checks whether module has method 'initialize'.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(module_ctx)
        module_ctx.local_nodes(:def) do |node| # FIXME: also search for :defs?
          if node.name.to_s == 'initialize'
            return [
              SmellWarning.new(self, context: module_ctx.full_name,
                                     lines:   [module_ctx.exp.line],
                                     message: 'has initialize method')
            ]
          end
        end
        []
      end
    end
  end
end
