require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/source/code_comment'

module Reek
  module Smells
    #
    # It is considered good practice to annotate every class and module
    # with a brief comment outlining its responsibilities.
    #
    class IrresponsibleModule < SmellDetector
      def self.contexts # :nodoc:
        [:class]
      end

      def self.descriptive   # :nodoc:
        @descriptive ||= {}
      end

      #
      # Checks the given class or module for a descriptive comment.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        comment = Source::CodeComment.new(ctx.exp.comments)
        return [] if self.class.descriptive[ctx.full_name] ||= comment.descriptive?
        [SmellWarning.new(self,
                          context: ctx.full_name,
                          lines: [ctx.exp.line],
                          message: 'has no descriptive comment',
                          parameters: {  name: ctx.exp.text_name })]
      end
    end
  end
end
