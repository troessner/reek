module Reek
  module Source
    #
    # Extensions to +Sexp+ to allow +CodeParser+ to navigate the abstract
    # syntax tree more easily.
    #
    module SexpNode
      def self.format(expr)
        case expr
        when Sexp then expr.format_ruby
        else expr.to_s
        end
      end

      def hash
        self.inspect.hash
      end

      def is_language_node?
        Symbol === first
      end

      def has_type?(type)
        is_language_node? and first == type
      end

      def each_node(type, ignoring, &blk)
        if block_given?
          look_for(type, ignoring, &blk)
        else
          result = []
          look_for(type, ignoring) {|exp| result << exp}
          result
        end
      end

      def each_sexp
        each { |elem| yield elem if Sexp === elem }
      end

      #
      # Carries out a depth-first traversal of this syntax tree, yielding
      # every Sexp of type +target_type+. The traversal ignores any node
      # whose type is listed in the Array +ignoring+.
      #
      def look_for(target_type, ignoring = [], &blk)
        each_sexp do |elem|
          elem.look_for(target_type, ignoring, &blk) unless ignoring.include?(elem.first)
        end
        blk.call(self) if first == target_type
      end

      def has_nested_node?(target_type)
        look_for(target_type) { |elem| return true }
        false
      end

      def format_ruby
        Ruby2Ruby.new.process(deep_copy)
      end

      def deep_copy
        Sexp.new(*map { |elem| Sexp === elem ? elem.deep_copy : elem })
      end
    end
  end
end
