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
    # @api private
    class UncommunicativeParameterName < SmellDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'
      DEFAULT_REJECT_SET = [/^.$/, /[0-9]$/, /[A-Z]/, /^_/]

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
        self.reject_names = value(REJECT_KEY, ctx, DEFAULT_REJECT_SET)
        self.accept_names = value(ACCEPT_KEY, ctx, DEFAULT_ACCEPT_SET)
        context_expression = ctx.exp
        context_expression.parameter_names.select do |name|
          bad_name?(name) && ctx.uses_param?(name)
        end.map do |name|
          SmellWarning.new(self,
                           context: ctx.full_name,
                           lines: [context_expression.line],
                           message: "has the parameter name '#{name}'",
                           parameters: { name: name.to_s })
        end
      end

      def bad_name?(name)
        var = name.to_s.gsub(/^[@\*\&]*/, '')
        return false if var == '*' || accept_names.include?(var)
        reject_names.find { |patt| patt =~ var }
      end

      private

      private_attr_accessor :accept_names, :reject_names
    end
  end
end
