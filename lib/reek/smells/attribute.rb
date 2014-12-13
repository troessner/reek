require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/core/smell_configuration'

module Reek
  module Smells
    #
    # A class that publishes a getter or setter for an instance variable
    # invites client classes to become too intimate with its inner workings,
    # and in particular with its representation of state.
    #
    # Currently this detector raises a warning for every +attr+,
    # +attr_reader+, +attr_writer+ and +attr_accessor+ -- including those
    # that are private.
    #
    # TODO: Eliminate private attributes
    # TODO: Catch attributes declared "by hand"
    #
    class Attribute < SmellDetector
      def self.contexts # :nodoc:
        [:class, :module]
      end

      def self.default_config
        super.merge(Core::SmellConfiguration::ENABLED_KEY => false)
      end

      #
      # Checks whether the given class declares any attributes.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        attributes_in(ctx).map do |attribute, line|
          SmellWarning.new self,
                           context: ctx.full_name,
                           lines: [line],
                           message:  "declares the attribute #{attribute}",
                           parameters: { name: attribute.to_s }
        end
      end

      private

      def attributes_in(module_ctx)
        result = Set.new
        attr_defn_methods = [:attr, :attr_reader, :attr_writer, :attr_accessor]
        module_ctx.local_nodes(:send) do |call_node|
          if attr_defn_methods.include?(call_node.method_name)
            call_node.arg_names.each { |arg| result << [arg, call_node.line] }
          end
        end
        result
      end
    end
  end
end
