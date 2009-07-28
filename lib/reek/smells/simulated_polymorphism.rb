require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/sexp_formatter'

module Reek
  module Smells

    #
    # TBS
    #
    class SimulatedPolymorphism < SmellDetector

      def self.contexts      # :nodoc:
        [:class]
      end

      #
      # Checks ... TBS
      # Remembers any smells found.
      #
      def examine_context(klass)
        counts = Hash.new(0)
        klass.conditionals.each {|cond| counts[cond] += 1}
        counts.each {|key, val|
          found(klass, "tests #{SexpFormatter.format(key)} at least #{val} times") if val >= 3
        }
      end
    end
  end
end
