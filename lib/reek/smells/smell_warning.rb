# frozen_string_literal: true
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
      def_delegators :smell_detector, :smell_type

      # @note When using Reek's public API, you should not create SmellWarning
      #   objects yourself. This is why the initializer is not part of the
      #   public API.
      #
      # :reek:LongParameterList: { max_params: 6 }
      def initialize(smell_detector, context: '', lines:, message:,
                     source:, parameters: {})
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

      def report_on(listener)
        listener.found_smell(self)
      end

      # @public
      def to_hash
        stringified_params = Hash[parameters.map { |key, val| [key.to_s, val] }]
        base_hash.merge(stringified_params)
      end

      alias yaml_hash to_hash

      def base_message
        "#{smell_type}: #{context} #{message}"
      end

      def smell_class
        smell_detector.class
      end

      protected

      def sort_key
        [smell_type, context, message]
      end

      private

      def base_hash
        {
          'context'        => context,
          'lines'          => lines,
          'message'        => message,
          'smell_type'     => smell_type,
          'source'         => source
        }
      end
    end
  end
end
