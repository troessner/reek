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
      # Checks whether the given class or module declares any class variables.
      # Remembers any smells found.
      #
      def examine_context(mod)
        class_variables_in(mod).each do |cvar_name|
          found(mod, "declares the class variable #{cvar_name}")
        end
      end

      #
      # Collects the names of the class variables declared and/or used
      # in the given module.
      #
      def class_variables_in(mod)
        result = Set.new
        collector = proc { |cvar_node| result << cvar_node.name }
        [:cvar, :cvasgn, :cvdecl].each do |stmt_type|
          mod.each(stmt_type, [:class, :module], &collector)
        end
        result
      end
    end
  end
end
