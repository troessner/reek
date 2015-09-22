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
    class SmellWarning
      include Comparable
      extend Forwardable

      # @public
      attr_reader :context, :lines, :message, :parameters, :smell_detector, :source
      def_delegators :smell_detector, :smell_category, :smell_type

      COMPARABLE_ATTRIBUTES = %i(message lines context source parameters)

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

      def matches_attributes?(other_attributes = {})
        check_attributes_comparability(other_attributes)
        return false unless common_parameters_equal?(other_attributes[:parameters])
        other_attributes.delete(:parameters)
        other_attributes.all? do |other_key, other_value|
          send(other_key) == other_value
        end
      end

      def matches?(klass, other_attributes = {})
        matches_smell_type?(klass) && matches_attributes?(other_attributes)
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
        other_attributes.keys.each do |attr|
          unless COMPARABLE_ATTRIBUTES.include?(attr)
            raise ArgumentError, "The attribute '#{attr}' is not available for comparison"
          end
        end
      end

      def common_parameters_equal?(other_parameters)
        return true unless other_parameters
        other_keys = other_parameters.keys
        other_keys.each do |key|
          unless parameters.key?(key)
            raise ArgumentError, "The parameter #{key} you want to check for doesn't exist"
          end
        end
        parameters.values_at(*other_keys) == other_parameters.values
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
