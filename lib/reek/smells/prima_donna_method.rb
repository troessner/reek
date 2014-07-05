require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells
    # Excerpt from:
    # http://dablog.rubypal.com/2007/8/15/bang-methods-or-danger-will-rubyist
    # since this sums it up really well:
    # ------------------------------
    # The ! in method names that end with ! means, “This method is dangerous”
    # or, more precisely, this method is the “dangerous” version of an
    # equivalent method, with the same name minus the !.  “Danger” is relative;
    # the ! doesn’t mean anything at all unless the method name it’s in
    # corresponds to a similar but bang-less method name.  Don’t add ! to your
    # destructive (receiver-changing) methods’ names, unless you consider the
    # changing to be “dangerous” and you have a “non-dangerous” equivalent
    # method without the !.  If some arbitrary subset of destructive methods end
    # with !, then the whole point of ! gets distorted and diluted, and ! ceases
    # to convey any information whatsoever
    # ------------------------------
    # Such a method is called PrimaDonnaMethod and is reported as a smell.
    class PrimaDonnaMethod < SmellDetector
      SMELL_CLASS = smell_class_name
      SMELL_SUBCLASS = smell_class_name

      def self.contexts
        [:class]
      end

      def examine_context(ctx)
        ctx.node_instance_methods.map do |method_sexp|
          next unless method_sexp.ends_with_bang?
          next if method_or_attr_method_exist?(ctx, method_sexp)
          SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
                           %Q(has prima donna method `#{method_sexp.name}`),
                           @source, SMELL_SUBCLASS)
        end.compact
      end

      private

      def method_or_attr_method_exist?(ctx, method_sexp)
        method_without_bang_exist?(ctx, method_sexp) ||
          attr_call_exist?(ctx, method_sexp)
      end

      def method_without_bang_exist?(ctx, method_sexp)
        ctx.node_instance_methods.find do |sexp_item|
          sexp_item.name.to_s == method_sexp.name_without_bang
        end
      end

      def attr_call_exist?(ctx, method_sexp)
        ctx.local_nodes(:call).find do |sexp_item|
          [:attr_reader, :attr_accessor].include?(sexp_item.method_name) &&
            sexp_item.arg_names.map(&:to_s).include?(method_sexp.name_without_bang)
        end
      end
    end
  end
end
