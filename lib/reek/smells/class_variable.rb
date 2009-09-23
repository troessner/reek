require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # Class variables form part of the global runtime state, and as such make
    # it easy for one part of the system to accidentally or inadvertently
    # depend on another part of the system. So the system becomes more prone to
    # problems where changing something over here breaks something over there.
    # In particular, class variables can make it hard to set up tests (because
    # the context of the test includes all global state).
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
