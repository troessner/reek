$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    # 
    # A Utility Function is any instance method that has no
    # dependency on the state of the instance.
    #
    class UtilityFunction < Smell

      #
      # Checks whether the given +method+ is a utility function.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(method, report)
        return false if method.constructor? or
          method.calls.keys.length == 0 or
          method.num_statements == 0 or
          method.depends_on_self
        report << new(method)
      end

      def detailed_report
        "#{@context.to_s} doesn't depend on instance state"
      end
    end

  end
end
