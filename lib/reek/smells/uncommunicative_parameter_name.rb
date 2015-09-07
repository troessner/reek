require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # An Uncommunicative Name is a name that doesn't communicate its intent
    # well enough.
    #
    # Poor names make it hard for the reader to build a mental picture
    # of what's going on in the code. They can also be mis-interpreted;
    # and they hurt the flow of reading, because the reader must slow
    # down to interpret the names.
    #
    # Currently +UncommunicativeParameterName+ checks for
    # * 1-character names
    # * names ending with a number
    #
    # See {file:docs/Uncommunicative-Parameter-Name.md} for details.
    class UncommunicativeParameterName < SmellDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'
      DEFAULT_REJECT_PATTERNS = [/^.$/, /[0-9]$/, /[A-Z]/, /^_/]

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'
      DEFAULT_ACCEPT_NAMES = []

      def self.smell_category
        'UncommunicativeName'
      end

      def self.default_config
        super.merge(
          REJECT_KEY => DEFAULT_REJECT_PATTERNS,
          ACCEPT_KEY => DEFAULT_ACCEPT_NAMES
        )
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        context_expression = ctx.exp
        context_expression.parameter_names.select do |name|
          bad_name?(ctx, name) && ctx.uses_param?(name)
        end.map do |name|
          smell_warning(
            context: ctx,
            lines: [context_expression.line],
            message: "has the parameter name '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      private

      def bad_name?(ctx, name)
        sanitized_name = sanitize name
        return false if sanitized_name == '*' || accept_names(ctx).include?(sanitized_name)
        reject_patterns(ctx).any? { |pattern| sanitized_name.match pattern }
      end

      def reject_patterns(context)
        value(REJECT_KEY, context, DEFAULT_REJECT_PATTERNS)
      end

      def accept_names(context)
        value(ACCEPT_KEY, context, DEFAULT_ACCEPT_NAMES)
      end

      # :reek:UtilityFunction
      def sanitize(name)
        name.to_s.gsub(/^[@\*\&]*/, '')
      end
    end
  end
end
