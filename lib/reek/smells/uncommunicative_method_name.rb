require_relative 'smell_detector'

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
    # See docs/Uncommunicative-Method-Name for details.
    class UncommunicativeMethodName < SmellDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'
      DEFAULT_REJECT_SET = [/^[a-z]$/, /[0-9]$/, /[A-Z]/]

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'
      DEFAULT_ACCEPT_SET = []

      def self.smell_category
        'UncommunicativeName'
      end

      def self.default_config
        super.merge(
          REJECT_KEY => DEFAULT_REJECT_SET,
          ACCEPT_KEY => DEFAULT_ACCEPT_SET
        )
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @reject_names = value(REJECT_KEY, ctx, DEFAULT_REJECT_SET)
        @accept_names = value(ACCEPT_KEY, ctx, DEFAULT_ACCEPT_SET)
        name = ctx.name.to_s
        return [] if @accept_names.include?(ctx.full_name)
        var = name.gsub(/^[@\*\&]*/, '')
        return [] if @accept_names.include?(var)
        return [] unless @reject_names.find { |patt| patt =~ var }
        [SmellWarning.new(self,
                          context: ctx.full_name,
                          lines: [ctx.exp.line],
                          message: "has the name '#{name}'",
                          parameters: { name: name })]
      end
    end
  end
end
