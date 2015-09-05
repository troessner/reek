require_relative 'code_context'
require_relative '../ast/sexp_formatter'

module Reek
  module Context
    #
    # A context wrapper for any module found in a syntax tree.
    #
    class ModuleContext < CodeContext
      def node_instance_methods
        local_nodes(:def)
      end

      def descriptively_commented?
        CodeComment.new(exp.leading_comment).descriptive?
      end

      # A namespace module is a module (or class) that is only there for namespacing
      # purposes, and thus contains only nested constants, modules or classes.
      #
      # However, if the module is empty, it is not considered a namespace module.
      #
      # @return true if the module is a namespace module
      def namespace_module?
        return false if exp.type == :casgn
        contents = exp.children.last
        contents && contents.find_nodes([:def, :defs], [:casgn, :class, :module]).empty?
      end
    end
  end
end
