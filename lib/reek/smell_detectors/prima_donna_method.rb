# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
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
    class PrimaDonnaMethod < BaseDetector
      def self.contexts # :nodoc:
        [:class]
      end

      #
      # @param ctx [Context::ModuleContext]
      # @return [Array<SmellWarning>]
      #
      # Given this code:
      #
      # class Alfa
      #   def bravo!
      #   end
      # end
      #
      # An example `ctx` could look like this:
      #
      # s(:class,
      #   s(:const, nil, :Alfa), nil,
      #     s(:def, :bravo!,
      #       s(:args), nil))
      #
      def sniff(ctx)
        ctx.node_instance_methods.select do |method_sexp|
          prima_donna_method?(method_sexp, ctx)
        end.map do |method_sexp|
          name = method_sexp.name
          smell_warning(
            context: ctx,
            lines: [ctx.exp.line],
            message: "has prima donna method '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      private

      def prima_donna_method?(method_sexp, ctx)
        return false unless method_sexp.ends_with_bang?
        return false if ignore_method?(method_sexp, ctx)
        return false if version_without_bang_exists?(method_sexp, ctx)
        true
      end

      # :reek:UtilityFunction
      def version_without_bang_exists?(method_sexp, ctx)
        ctx.node_instance_methods.find do |sexp_item|
          sexp_item.name.to_s == method_sexp.name_without_bang
        end
      end

      #
      # @param method_node [Reek::AST::Node],
      #   e.g. s(:def, :bravo!, s(:args), nil)
      # @param ctx [Context::ModuleContext]
      # @return [Boolean]
      #
      def ignore_method?(method_node, ctx)
        ignore_method_names = value(EXCLUDE_KEY, ctx) # e.g. ["bravo!"]
        ignore_method_names.include? method_node.name.to_s # method_node.name is e.g.: :bravo!
      end
    end
  end
end
