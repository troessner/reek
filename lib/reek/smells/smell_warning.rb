require 'forwardable'

module Reek
  # @public
  module Smells
    #
    # Reports a warning that a smell has been found.
    #
    # @public
    #
    # :reek:TooManyInstanceVariables: { max_instance_variables: 6 }
    # :reek:TooManyStatements: { max_statements: 6 }
    class SmellWarning
      include Comparable
      extend Forwardable

      # @public
      attr_reader :context, :lines, :message, :parameters, :smell_detector, :source
      def_delegators :smell_detector, :smell_category, :smell_type

      COMPARABLE_ATTRIBUTES = %i(message lines context source)

      # @note When using reek's public API, you should not create SmellWarning
      #   objects yourself. This is why the initializer is not part of the
      #   public API.
      #
      # FIXME: switch to required kwargs when dropping Ruby 2.0 compatibility
      #
      # :reek:LongParameterList: { max_params: 6 }
      def initialize(smell_detector, context: '', lines: raise, message: raise,
                                     source: raise, parameters: {})
        @smell_detector = smell_detector
        @source         = source
        @context        = context.to_s
        @lines          = lines
        @message        = message
        @parameters     = parameters
      end

      # @public
      def hash
        sort_key.hash
      end

      # @public
      def <=>(other)
        sort_key <=> other.sort_key
      end

      # @public
      def eql?(other)
        (self <=> other) == 0
      end

      def matches_smell_type?(klass)
        smell_classes.include?(klass.to_s)
      end

      def matches_attributes?(attributes = {})
        check_attributes_comparability(attributes)
        main_attributes = attributes.slice(*COMPARABLE_ATTRIBUTES)
        paramater_attributes = attributes.except(*COMPARABLE_ATTRIBUTES)
        return false unless common_parameters_equal?(paramater_attributes)
        main_attributes.all? do |other_key, other_value|
          send(other_key) == other_value
        end
      end

      def matches?(klass, attributes = {})
        matches_smell_type?(klass) && matches_attributes?(attributes)
      end

      def report_on(listener)
        listener.found_smell(self)
      end

      # @public
      def yaml_hash
        stringified_params = Hash[parameters.map { |key, val| [key.to_s, val] }]
        core_yaml_hash.
          merge(stringified_params)
      end

      def base_message
        "#{context} #{message} (#{smell_type})"
      end

      protected

      def sort_key
        [context, message, smell_category]
      end

      private

      def smell_classes
        [smell_detector.smell_category, smell_detector.smell_type]
      end

      def check_attributes_comparability(other_attributes)
        parameter_keys = other_attributes.keys - COMPARABLE_ATTRIBUTES
        extra_keys = parameter_keys - parameters.keys
        return if extra_keys.empty?
        raise ArgumentError, "The attribute '#{extra_keys.first}' is not available for comparison"
      end

      def common_parameters_equal?(other_parameters)
        parameters.slice(*other_parameters.keys) == other_parameters
      end

      def core_yaml_hash
        {
          'context'        => context,
          'lines'          => lines,
          'message'        => message,
          'smell_category' => smell_category,
          'smell_type'     => smell_type,
          'source'         => source
        }
      end
    end
  end
end
