require 'reek/smells/smell_detector'

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

      def initialize(source = '???', config = Attribute.default_config)
        super(source, config)
      end

      #
      # Checks whether the given class declares any attributes.
      # Remembers any smells found.
      #
      def examine_context(mod)
        attributes_in(mod).each do |attr|
          found(mod, "declares the attribute #{attr}", '', {'attribute' => attr.to_s})
        end
      end

      #
      # Collects the names of the class variables declared and/or used
      # in the given module.
      #
      def attributes_in(mod)
        result = Set.new
        mod.local_nodes(:call) do |call_node|
          if ATTRIBUTE_METHODS.include?(call_node.method_name)
            call_node.arg_names.each {|arg| result << arg }
          end
        end
        result
      end
    end
  end
end
