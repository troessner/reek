require 'set'
require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

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

      SMELL_CLASS = self.name.split(/::/)[-1]
      SMELL_SUBCLASS = SMELL_CLASS
      VARIABLE_KEY = 'variable'

      def self.contexts      # :nodoc:
        [:class, :module]
      end

      #
      # Checks whether the given class or module declares any class variables.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        class_variables_in(ctx.exp).each do |cvar_node|
          smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [cvar_node.line],
            "declares the class variable #{cvar_node.name}",
            @source, SMELL_SUBCLASS,
            {VARIABLE_KEY => cvar_node.name.to_s})
          @smells_found << smell
          #SMELL: serious duplication
        end
      end

      #
      # Collects the names of the class variables declared and/or used
      # in the given module.
      #
      def class_variables_in(ast)
        result = Set.new
        collector = proc { |cvar_node| result << cvar_node }
        [:cvar, :cvasgn, :cvdecl].each do |stmt_type|
          ast.each_node(stmt_type, [:class, :module], &collector)
        end
        result
      end
    end
  end
end
