require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells
    #
    # a module is usually a mixin, so when initialize method is present it is
    # hard to tell initialization order and parameters so having 'initialize'
    # in a module is usually a bad idea
    #
    class ModuleInitialize < SmellDetector
      SMELL_CLASS = smell_class_name
      SMELL_SUBCLASS = SMELL_CLASS

      def self.contexts      # :nodoc:
        [:module]
      end

      #
      # Checks whether module has method 'initialize'.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(module_ctx)
        module_ctx.local_nodes(:defn) do |node| # FIXME: also search for :defs?
          if node.name.to_s == 'initialize'
            return [
              SmellWarning.new(SMELL_CLASS, module_ctx.full_name, [module_ctx.exp.line],
                               'has initialize method',
                               @source, SMELL_SUBCLASS, {})
            ]
          end
        end
        []
      end
    end
  end
end
