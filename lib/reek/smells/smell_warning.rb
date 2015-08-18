require 'forwardable'

module Reek
  module Smells
    #
    # Reports a warning that a smell has been found.
    #
    class SmellWarning
      include Comparable
      extend Forwardable
      attr_reader :context, :lines, :message, :parameters, :smell_detector
      def_delegators :smell_detector, :smell_category, :smell_type, :source

      def initialize(smell_detector, options = {})
        @smell_detector = smell_detector
        @context        = options.fetch(:context, '').to_s
        @lines          = options.fetch(:lines)
        @message        = options.fetch(:message)
        @parameters     = options.fetch(:parameters, {})
      end

      def hash
        sort_key.hash
      end

      def <=>(other)
        sort_key <=> other.sort_key
      end

      def eql?(other)
        (self <=> other) == 0
      end

      # @api private
      def matches?(klass, other_parameters = {})
        smell_classes.include?(klass.to_s) && common_parameters_equal?(other_parameters)
      end

      # @api private
      def report_on(listener)
        listener.found_smell(self)
      end

      def yaml_hash(warning_formatter = nil)
        stringified_params = Hash[parameters.map { |key, val| [key.to_s, val] }]
        core_yaml_hash.
          merge(stringified_params).
          merge(wiki_link_hash(warning_formatter))
      end

      protected

      def sort_key
        [context, message, smell_category]
      end

      private

      def smell_classes
        [smell_detector.smell_category, smell_detector.smell_type]
      end

      def common_parameters_equal?(other_parameters)
        other_parameters.keys.each do |key|
          unless parameters.key?(key)
            raise ArgumentError, "The parameter #{key} you want to check for doesn't exist"
          end
        end

        # Why not check for strict parameter equality instead of just the common ones?
        #
        # In `self`, `parameters` might look like this:  {:name=>"@other.thing", :count=>2}
        # Coming from specs, 'other_parameters' might look like this, e.g.:
        # {:name=>"@other.thing"}
        # So in this spec we are just specifying the "name" parameter but not the "count".
        # In order to allow for this kind of leniency we just test for common parameter equality,
        # not for a strict one.
        parameters.values_at(*other_parameters.keys) == other_parameters.values
      end

      def core_yaml_hash
        {
          'context'        => context,
          'lines'          => lines,
          'message'        => message,
          'smell_category' => smell_detector.smell_category,
          'smell_type'     => smell_detector.smell_type,
          'source'         => smell_detector.source
        }
      end

      def wiki_link_hash(warning_formatter)
        if warning_formatter.respond_to?(:explanatory_link)
          { 'wiki_link' => warning_formatter.explanatory_link(smell_detector) }
        else
          {}
        end
      end
    end
  end
end
