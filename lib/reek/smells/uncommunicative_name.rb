require 'reek/smells/smell_detector'
require 'reek/smell_warning'

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
    # Currently +UncommunicativeName+ checks for
    # * 1-character names
    # * names consisting of a single character followed by a number
    #
    class UncommunicativeName < SmellDetector

      # The name of the config field that lists the regexps of
      # smelly names to be rejected.
      REJECT_KEY = 'reject'
      
      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'

      def self.default_config
        super.adopt(
          REJECT_KEY => [/^.[0-9]*$/],
          ACCEPT_KEY => ['Inline::C']
        )
      end

      def self.contexts      # :nodoc:
        [:module, :class, :defn, :defs, :iter]
      end

      def initialize(config = UncommunicativeName.default_config)
        super(config)
      end

      #
      # Checks the given +context+ for uncommunicative names.
      # Remembers any smells found.
      #
      def examine_context(context)
        consider_name(context)
        consider_variables(context)
      end

      def consider_variables(context) # :nodoc:
        context.variable_names.each do |name|
          next unless is_bad_name?(name)
          found(context, "has the variable name '#{name}'")
        end
      end

      def consider_name(context)  # :nodoc:
        name = context.name
        return false if @config[ACCEPT_KEY].include?(context.to_s)  # TODO: fq_name() ?
        return false unless is_bad_name?(name)
        found(context, "has the name '#{name}'")
      end

      def is_bad_name?(name)  # :nodoc:
        var = name.effective_name
        return false if var == '*' or @config[ACCEPT_KEY].include?(var)
        @config[REJECT_KEY].detect {|patt| patt === var}
      end
    end
  end
end
