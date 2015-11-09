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
    # Currently +UncommunicativeMethodName+ checks for
    # * 1-character names
    # * names ending with a number
    #
    # See {file:docs/Uncommunicative-Method-Name.md} for details.
    class UncommunicativeMethodName < SmellDetector
      REJECT_KEY = 'reject'
      ACCEPT_KEY = 'accept'
      DEFAULT_REJECT_PATTERNS = [/^[a-z]$/, /[0-9]$/, /[A-Z]/]
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
      def inspect(context)
        name = context.name.to_s
        return [] if acceptable_name?(name: name, context: context)

        [smell_warning(
          context: context,
          lines: [context.exp.line],
          message: "has the name '#{name}'",
          parameters: { name: name })]
      end

      private

      def acceptable_name?(name: raise, context: raise)
        accept_names(context).any? { |accept_name| name == accept_name } ||
          reject_patterns(context).none? { |pattern| name.match pattern }
      end

      def reject_patterns(context)
        value(REJECT_KEY, context, DEFAULT_REJECT_PATTERNS)
      end

      def accept_names(context)
        value(ACCEPT_KEY, context, DEFAULT_ACCEPT_NAMES)
      end
    end
  end
end
