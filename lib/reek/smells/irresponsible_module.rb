require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'source')

module Reek
  module Smells

    #
    # It is considered good practice to annotate every class and module
    # with a brief comment outlining its responsibilities.
    #
    class IrresponsibleModule < SmellDetector

      SMELL_CLASS = self.name.split(/::/)[-1]
      SMELL_SUBCLASS = SMELL_CLASS

      MODULE_NAME_KEY = 'module_name'

      def self.contexts      # :nodoc:
        [:class]
      end

      #
      # Checks the given class or module for a descriptive comment.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        comment = Source::CodeComment.new(ctx.exp.comments)
        return [] if comment.is_descriptive?
        smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
          'has no descriptive comment',
          @source, SMELL_SUBCLASS, {MODULE_NAME_KEY => ctx.exp.text_name})
        [smell]
      end
    end
  end
end
