require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # TBS
    #
    class ClassVariable < SmellDetector

      def self.contexts      # :nodoc:
        [:class, :module]
      end

      #
      # Checks whether the given class declares any class variables.
      # Remembers any smells found.
      #
      def examine_context(klass)
        klass.class_variables.each do |cvar|
          found(klass, "declares the class variable #{cvar}")
        end
      end
    end
  end
end
