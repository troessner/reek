# frozen_string_literal: true

require_relative '../cli/silencer'

Reek::CLI::Silencer.silently do
  require 'parser'
end

module Reek
  module AST
    # Base class for AST nodes extended with utility methods. Contains some
    # methods to ease the transition from Sexp to AST::Node.
    #
    class Node < ::Parser::AST::Node
      def initialize(type, children = [], options = {})
        @comments = options.fetch(:comments, [])
        super
      end

      def full_comment
        comments.map(&:text).join("\n")
      end

      def leading_comment
        line = location.line
        comment_lines = comments.select do |comment|
          comment.location.line < line
        end
        comment_lines.map(&:text).join("\n")
      end

      def line
        loc && loc.line
      end

      #
      # Carries out a depth-first traversal of this syntax tree, yielding
      # every Sexp of type `target_type`. The traversal ignores any node
      # whose type is listed in the Array `ignoring`.
      # Takes a block as well.
      #
      # target_type - the type to look for, e.g. :send, :block
      # ignoring - types to ignore, e.g. [:casgn, :class, :module]
      # blk - block to execute for every hit. Gets passed in the matching element itself.
      #
      # Examples:
      #   context.each_node(:send, [:mlhs]) do |call_node| .... end
      #   context.each_node(:lvar).any? { |it| it.var_name == 'something' }
      #
      # Returns an array with all matching nodes.
      # TODO: without a block, this doesn't do what one might expect
      def each_node(target_type, ignoring = [], &blk)
        if block_given?
          look_for_type(target_type, ignoring, &blk)
        else
          result = []
          look_for_type(target_type, ignoring) { |exp| result << exp }
          result
        end
      end

      #
      # Carries out a depth-first traversal of this syntax tree, yielding
      # every Sexp of type `target_type`. The traversal ignores any node
      # whose type is listed in the Array `ignoring`, including the top node.
      # Takes a block as well.
      #
      # target_types - the types to look for, e.g. [:send, :block]
      # ignoring - types to ignore, e.g. [:casgn, :class, :module]
      # blk - block to execute for every hit
      #
      # Examples:
      #   exp.find_nodes([:block]).flat_map do |elem| ... end
      #
      # Returns an array with all matching nodes.
      def find_nodes(target_types, ignoring = [])
        result = []
        look_for_types(target_types, ignoring) { |exp| result << exp }
        result
      end

      def contains_nested_node?(target_type)
        look_for_type(target_type) { |_elem| return true }
        false
      end

      # :reek:DuplicateMethodCall { max_calls: 2 } is ok for lines.first
      # :reek:FeatureEnvy
      def format_to_ruby
        if location
          lines = location.expression.source.split("\n").map(&:strip)
          case lines.length
          when 1 then lines.first
          when 2 then lines.join('; ')
          else [lines.first, lines.last].join(' ... ')
          end
        else
          to_s
        end
      end

      # Provide length for statement counting. A sexp counts as one statement.
      def length
        1
      end

      # Most nodes represent only one statement (although they can have nested
      # statements). The special type :begin exists primarily to contain more
      # statements.
      #
      # @return Array of unique outer-level statements contained in this node
      def statements
        [self]
      end

      def source
        loc.expression.source_buffer.name
      end

      protected

      # See ".each_node" for documentation.
      def look_for_type(target_type, ignoring = [], &blk)
        each_sexp do |elem|
          elem.look_for_type(target_type, ignoring, &blk) unless ignoring.include?(elem.type)
        end
        yield self if type == target_type
      end

      # See ".find_nodes" for documentation.
      def look_for_types(target_types, ignoring = [], &blk)
        return if ignoring.include?(type)
        if target_types.include? type
          yield self
        else
          each_sexp do |elem|
            elem.look_for_types(target_types, ignoring, &blk)
          end
        end
      end

      private

      attr_reader :comments

      def each_sexp
        children.each { |elem| yield elem if elem.is_a? ::Parser::AST::Node }
      end
    end
  end
end
