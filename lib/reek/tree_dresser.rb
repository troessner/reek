module Reek

  #
  # Extensions to +Sexp+ to allow +CodeParser+ to navigate the abstract
  # syntax tree more easily.
  #
  module SexpNode
    def children
      find_all { |item| Sexp === item }
    end

    def is_language_node?
      first.class == Symbol
    end

    def has_type?(type)
      is_language_node? and first == type
    end

    #
    # Carries out a depth-first traversal of this syntax tree, yielding
    # every Sexp of type +target_type+. The traversal ignores any node
    # whose type is listed in the Array +ignoring+.
    #
    def look_for(target_type, ignoring, &blk)
      each do |elem|
        if Sexp === elem then
          elem.look_for(target_type, ignoring, &blk) unless ignoring.include?(elem.first)
        end
      end
      blk.call(self) if first == target_type
    end
  end

  module CvarNode
    def name
      self[1]
    end
  end

  module IfNode
    def condition
      self[1]
    end
  end

  module CaseNode
    def condition
      self[1]
    end
  end

  class TreeDresser
    # SMELL: Duplication
    # Put these into a new module and build the mapping automagically
    # based on the node type
    EXTENSIONS = {
      :cvar => CvarNode,
      :cvasgn => CvarNode,
      :cvdecl => CvarNode,
      :if => IfNode,
      :case => CaseNode,
    }

    def dress(sexp)
      sexp.extend(SexpNode)
      if EXTENSIONS.has_key?(sexp[0])
        sexp.extend(EXTENSIONS[sexp[0]])
      end
      sexp[0..-1].each { |sub| dress(sub) if Array === sub }
      sexp
    end
  end
end
