require_relative 'smell_detector'
require_relative '../core/smell_configuration'

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
    # TODO: Catch attributes declared "by hand"
    # See docs/Attribute for details.
    #
    class Attribute < SmellDetector
      ATTR_DEFN_METHODS = [:attr, :attr_reader, :attr_writer, :attr_accessor]
      VISIBILITY_MODIFIERS = [:private, :public, :protected]

      def initialize(*args)
        @visiblity_tracker = {}
        @visiblity_mode = :public
        @result = Set.new
        super
      end

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
        module_ctx.local_nodes(:send) do |call_node|
          if visibility_modifier?(call_node)
            track_visibility(call_node)
          elsif ATTR_DEFN_METHODS.include?(call_node.method_name)
            call_node.arg_names.each do |arg|
              @visiblity_tracker[arg] = @visiblity_mode
              @result << [arg, call_node.line]
            end
          end
        end
        @result.select { |args| recorded_public_methods.include?(args[0]) }
      end

      def visibility_modifier?(call_node)
        VISIBILITY_MODIFIERS.include?(call_node.method_name)
      end

      def track_visibility(call_node)
        if call_node.arg_names.any?
          call_node.arg_names.each { |arg| @visiblity_tracker[arg] = call_node.method_name }
        else
          @visiblity_mode = call_node.method_name
        end
      end

      def recorded_public_methods
        @visiblity_tracker.select { |_, visbility| visbility == :public }
      end
    end
  end
end
