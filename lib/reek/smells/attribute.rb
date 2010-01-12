require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

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
    # TODO:
    # * eliminate private attributes
    # * catch attributes declared "by hand"
    #
    class Attribute < SmellDetector

      ATTRIBUTE_METHODS = [:attr, :attr_reader, :attr_writer, :attr_accessor]

      def self.contexts      # :nodoc:
        [:class, :module]
      end

      def self.default_config
        super.adopt(SmellConfiguration::ENABLED_KEY => false)
      end

      def initialize(source, config = Attribute.default_config)
        super(source, config)
      end

      #
      # Checks whether the given class declares any attributes.
      # Remembers any smells found.
      #
      def examine_context(module_ctx)
        attributes_in(module_ctx).each do |attr, line|
          found(module_ctx, "declares the attribute #{attr}", '',
            {'attribute' => attr.to_s}, [line])
        end
      end

      #
      # Collects the names of the class variables declared and/or used
      # in the given module.
      #
      def attributes_in(module_ctx)
        result = Set.new
        module_ctx.local_nodes(:call) do |call_node|
          if ATTRIBUTE_METHODS.include?(call_node.method_name)
            call_node.arg_names.each {|arg| result << [arg, call_node.line] }
          end
        end
        result
      end
    end
  end
end
