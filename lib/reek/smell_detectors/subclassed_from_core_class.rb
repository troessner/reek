# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # Subclassing core classes in Ruby can lead to unexpected side effects.
    # Knowing that Ruby has a core library, which is written in C, and a standard
    # library, which is written in Ruby, if you do not know exactly how these core
    # classes operate at the C level, you are gonna have a bad time.
    #
    # Source: http://words.steveklabnik.com/beware-subclassing-ruby-core-classes
    #
    class SubclassedFromCoreClass < BaseDetector
      CORE_CLASSES = ['Array', 'Hash', 'String'].freeze

      def self.contexts
        [:class, :casgn]
      end

      # Checks +ctx+ for either expressions:
      #
      # Foo = Class.new(Bar)
      #
      # class Foo < Bar; end;
      #
      # @return [Array<SmellWarning>]
      def sniff(ctx)
        superclass = ctx.exp.superclass

        return [] unless superclass

        sniff_superclass(ctx, superclass.name)
      end

      private

      def sniff_superclass(ctx, superclass_name)
        return [] unless CORE_CLASSES.include?(superclass_name)

        [build_smell_warning(ctx, superclass_name)]
      end

      def build_smell_warning(ctx, ancestor_name)
        smell_attributes = {
          context: ctx,
          lines: [ctx.exp.line],
          message: "inherits from core class '#{ancestor_name}'",
          parameters: { ancestor: ancestor_name }
        }

        smell_warning(smell_attributes)
      end
    end
  end
end
