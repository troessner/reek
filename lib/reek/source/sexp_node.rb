module Reek
  module Source
    #
    # Extensions to +Sexp+ to allow +CodeParser+ to navigate the abstract
    # syntax tree more easily.
    #
    module SexpNode
      def self.format(expr)
        case expr
        when AST::Node then expr.format_ruby
        else expr.to_s
        end
      end

      def hash
        inspect.hash
      end

      def each_node(type, ignoring = [], &blk)
        if block_given?
          look_for(type, ignoring, &blk)
        else
          result = []
          look_for(type, ignoring) { |exp| result << exp }
          result
        end
      end

      def find_nodes(types, ignoring = [])
        result = []
        look_for_alt(types, ignoring) { |exp| result << exp }
        result
      end

      def each_sexp
        children.each { |elem| yield elem if elem.is_a? AST::Node }
      end

      #
      # Carries out a depth-first traversal of this syntax tree, yielding
      # every Sexp of type +target_type+. The traversal ignores any node
      # whose type is listed in the Array +ignoring+.
      #
      def look_for(target_type, ignoring = [], &blk)
        each_sexp do |elem|
          elem.look_for(target_type, ignoring, &blk) unless ignoring.include?(elem.type)
        end
        blk.call(self) if type == target_type
      end

      #
      # Carries out a depth-first traversal of this syntax tree, yielding
      # every Sexp of type +target_type+. The traversal ignores any node
      # whose type is listed in the Array +ignoring+, includeing the top node.
      #
      # Also, doesn't nest
      #
      def look_for_alt(target_types, ignoring = [], &blk)
        return if ignoring.include?(type)
        if target_types.include? type
          blk.call(self)
        else
          each_sexp do |elem|
            elem.look_for_alt(target_types, ignoring, &blk)
          end
        end
      end

      def contains_nested_node?(target_type)
        look_for(target_type) { |_elem| return true }
        false
      end

      def format_ruby
        SexpFormatter.format(self)
      end
    end
  end
end
