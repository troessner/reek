# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    # Excerpt from:
    # http://dablog.rubypal.com/2007/8/15/bang-methods-or-danger-will-rubyist
    # since this sums it up really well:
    #
    #   The ! in method names that end with ! means, "This method is dangerous"
    #   -- or, more precisely, this method is the "dangerous" version of an
    #   equivalent method, with the same name minus the !. "Danger" is
    #   relative; the ! doesn't mean anything at all unless the method name
    #   it's in corresponds to a similar but bang-less method name.
    #
    #   Don't add ! to your destructive (receiver-changing) methods' names,
    #   unless you consider the changing to be "dangerous" and you have a
    #   "non-dangerous" equivalent method without the !. If some arbitrary
    #   subset of destructive methods end with !, then the whole point of !
    #   gets distorted and diluted, and ! ceases to convey any information
    #   whatsoever.
    #
    # Such a method is called PrimaDonnaMethod and is reported as a smell.
    #
    # See {file:docs/Prima-Donna-Method.md} for details.
    class PrimaDonnaMethod < SmellDetector
      def self.contexts # :nodoc:
        [:class]
      end

      def inspect(ctx)
        ctx.node_instance_methods.map do |method_sexp|
          check_for_smells(method_sexp, ctx)
        end.compact
      end

      private

      # :reek:FeatureEnvy
      def check_for_smells(method_sexp, ctx)
        return unless method_sexp.ends_with_bang?

        version_without_bang = ctx.node_instance_methods.find do |sexp_item|
          sexp_item.name.to_s == method_sexp.name_without_bang
        end

        return if version_without_bang
        smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "has prima donna method `#{method_sexp.name}`",
          parameters: { name: ctx.name })
      end
    end
  end
end
