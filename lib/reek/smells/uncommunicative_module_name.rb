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
    # Currently +UncommunicativeModuleName+ checks for
    # * 1-character names
    # * names ending with a number
    #
    # See {file:docs/Uncommunicative-Module-Name.md} for details.
    class UncommunicativeModuleName < SmellDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'
      DEFAULT_REJECT_PATTERNS = [/^.$/, /[0-9]$/]

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'
      DEFAULT_ACCEPT_PATTERNS = [/Inline::C/]

      def self.smell_category
        'UncommunicativeName'
      end

      def self.default_config
        super.merge(
          REJECT_KEY => DEFAULT_REJECT_PATTERNS,
          ACCEPT_KEY => DEFAULT_ACCEPT_PATTERNS
        )
      end

      def self.contexts
        [:module, :class]
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(context)
        fully_qualified_name = context.full_name
        exp                  = context.exp
        module_name          = exp.simple_name

        return [] if acceptable_name?(context: context,
                                      module_name: module_name,
                                      fully_qualified_name: fully_qualified_name)

        [smell_warning(
          context: context,
          lines: [exp.line],
          message: "has the name '#{module_name}'",
          parameters: { name: module_name })]
      end

      private

      # FIXME: switch to required kwargs when dropping Ruby 2.0 compatibility
      def acceptable_name?(context: raise, module_name: raise, fully_qualified_name: raise)
        accept_patterns(context).any? { |pattern| fully_qualified_name.match pattern } ||
          reject_patterns(context).none? { |pattern| module_name.match pattern }
      end

      def reject_patterns(context)
        value(REJECT_KEY, context, DEFAULT_REJECT_PATTERNS)
      end

      def accept_patterns(context)
        value(ACCEPT_KEY, context, DEFAULT_ACCEPT_PATTERNS)
      end
    end
  end
end
