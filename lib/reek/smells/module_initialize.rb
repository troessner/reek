require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    #
    # a module is usually a mixin, so when initialize method is present it is hard to tell initialization order and parameters
    # so having 'initialize' in a module is usually a bad idea
    #
    class ModuleInitialize < SmellDetector

      SMELL_CLASS = self.name.split(/::/)[-1]
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      def self.contexts      # :nodoc:
        [:module]
      end

      #  => s(:module, :A,
      #  s(:scope,
      #    s(:block,
      #      s(:defn, :initialize, s(:args), s(:scope, s(:block, s(:iasgn, :@a, s(:lit, 2))))),
      #      s(:defn, :b, s(:args), s(:scope, s(:block, s(:nil))))))) 

      #
      # Checks whether module has method 'initialize'.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(module_ctx)
        module_ctx.local_nodes(:defn) do|s_type, name| #FIXME: also search for :defs?
          if name.to_s == 'initialize'
            return [
              SmellWarning.new(SMELL_CLASS, module_ctx.full_name, [module_ctx.exp.line],
                           "has initialize method",
                           @source, SMELL_SUBCLASS, {})
            ]
          end
        end
        []
      end
    end
  end
end
