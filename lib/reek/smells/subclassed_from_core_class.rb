# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # Subclassing core classes in Ruby can lead to unexpected side effects.
    # Knowing that Ruby has a core library (Written in C) and a standard
    # library (Written in Ruby), if you don’t know exactly how these core 
    # classes operate at the C level, you’re gonna have a bad time.
    #
    # Source: http://words.steveklabnik.com/beware-subclassing-ruby-core-classes
    #
    class SubclassedFromCoreClass < SmellDetector

      METHODS = {
        casgn: :inspect_casgn,
        class: :inspect_class,
      }.freeze

      def self.contexts
        [:class, :casgn]
      end

      # Checks +ctx+ for if it is subclasssed from a core class
      #
      # @return [Array<SmellWarning>]
      def inspect(ctx)
        public_send(METHODS[ctx.type], ctx)
      end

      def inspect_class(ctx)
        superclass = ctx.exp.ancestor

        return [] unless superclass && superclass.core_class?

        [build_smell_warning(ctx, superclass)]
      end

      def inspect_casgn(ctx)
        ctx.exp.class_creation? ? inspect_class(ctx) : []
      end

      private

      def build_smell_warning(ctx, ancestor)
        exp = ctx.exp

        smell_warning({ 
          context: ctx,
          lines: [exp.line],
          message: "inherits from a core class #{ancestor}",
          parameters: { ancestor: ancestor.name }
        })
      end
    end
  end
end
