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
    # @api private
    class UncommunicativeModuleName < SmellDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'
      DEFAULT_REJECT_SET = [/^.$/, /[0-9]$/]

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'
      DEFAULT_ACCEPT_SET = ['Inline::C']

      def self.smell_category
        'UncommunicativeName'
      end

      def self.default_config
        super.merge(
          REJECT_KEY => DEFAULT_REJECT_SET,
          ACCEPT_KEY => DEFAULT_ACCEPT_SET
        )
      end

      def self.contexts      # :nodoc:
        [:module, :class]
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      # :reek:Duplication { allow_calls: [ to_s ] }
      def examine_context(ctx)
        reject_names = value(REJECT_KEY, ctx, DEFAULT_REJECT_SET)
        accept_names = value(ACCEPT_KEY, ctx, DEFAULT_ACCEPT_SET)
        exp = ctx.exp
        full_name = ctx.full_name
        name = exp.simple_name.to_s
        return [] if accept_names.include?(full_name)
        var = name.gsub(/^[@\*\&]*/, '')
        return [] if accept_names.include?(var)
        return [] unless reject_names.find { |patt| patt =~ var }
        [SmellWarning.new(self,
                          context: full_name,
                          lines: [exp.line],
                          message: "has the name '#{name}'",
                          parameters: { name: name })]
      end
    end
  end
end
