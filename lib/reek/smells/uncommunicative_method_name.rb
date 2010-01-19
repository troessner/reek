require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

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
    class UncommunicativeMethodName < SmellDetector

      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'

      DEFAULT_REJECT_SET = [/^.$/, /[0-9]$/]
      
      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'

      DEFAULT_ACCEPT_SET = []

      def self.default_config
        super.adopt(
          REJECT_KEY => DEFAULT_REJECT_SET,
          ACCEPT_KEY => DEFAULT_ACCEPT_SET
        )
      end

      def self.contexts      # :nodoc:
        [:defn, :defs]
      end

      def initialize(source, config = UncommunicativeMethodName.default_config)
        super(source, config)
      end

      #
      # Checks the given +context+ for uncommunicative names.
      # Remembers any smells found.
      #
      def examine_context(method_ctx)
        name = method_ctx.name
        return false if accept?(method_ctx)
        return false unless is_bad_name?(name, method_ctx)
        smell = SmellWarning.new('UncommunicativeName', method_ctx.full_name, [method_ctx.exp.line],
          "has the name '#{name}'", @masked,
          @source, 'UncommunicativeMethodName', {'method_name' => name.to_s})
        @smells_found << smell
        #SMELL: serious duplication
      end

      def accept?(context)
        value(ACCEPT_KEY, context, DEFAULT_ACCEPT_SET).include?(context.full_name)
      end

      def is_bad_name?(name, context)  # :nodoc:
        var = name.to_s.gsub(/^[@\*\&]*/, '')
        return false if value(ACCEPT_KEY, context, DEFAULT_ACCEPT_SET).include?(var)
        value(REJECT_KEY, context, DEFAULT_REJECT_SET).detect {|patt| patt === var}
      end
    end
  end
end
