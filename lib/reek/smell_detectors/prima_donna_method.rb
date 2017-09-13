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
      # @return [Array<SmellWarning>]
      #
      # Given this code:
      #
      # class Alfa
      #   def bravo!
      #   end
      # end
      #
      # An example context could look like this:
      #
      # s(:class,
      #   s(:const, nil, :Alfa), nil,
      #     s(:def, :bravo!,
      #       s(:args), nil))
      #
      def sniff
        context.node_instance_methods.select do |method_sexp|
          prima_donna_method?(method_sexp)
        end.map do |method_sexp|
          name = method_sexp.name
          smell_warning(
            context: context,
            lines: [method_sexp.line],
            message: "has prima donna method '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      private

      def prima_donna_method?(method_sexp)
        return false unless method_sexp.ends_with_bang?
        return false if ignore_method? method_sexp
        return false if version_without_bang_exists? method_sexp
        true
      end

      def version_without_bang_exists?(method_sexp)
        context.node_instance_methods.find do |sexp_item|
          sexp_item.name.to_s == method_sexp.name_without_bang
        end
      end

      #
      # @param method_node [Reek::AST::Node],
      #   e.g. s(:def, :bravo!, s(:args), nil)
      # @return [Boolean]
      #
      def ignore_method?(method_node)
        ignore_method_names.include? method_node.name.to_s # method_node.name is e.g.: :bravo!
      end

      # e.g. ["bravo!"]
      def ignore_method_names
        @ignore_method_names ||= value(EXCLUDE_KEY, context)
      end
    end
  end
end
