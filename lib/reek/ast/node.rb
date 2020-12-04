# frozen_string_literal: true

require_relative '../cli/silencer'
Reek::CLI::Silencer.without_warnings { require 'parser' }

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

      def name
        to_s
      end

      #
      # Carries out a depth-first traversal of this syntax tree, yielding every
      # Sexp of the searched for type or types. The traversal stops at any node
      # whose type is listed in `ignoring`.
      #
      # If a type is searched for *and* listed in ignoring, it will be yielded
      # but traversal will not continue to its children.
      #
      # If the root's type is ignored, traversal does not stop, unless the root
      # is of a target type.
      #
      # Takes a block as well.
      #
      # @param target_types [Symbol, Array<Symbol>] the type or types to look
      #     for
      # @param ignoring [Array<Symbol>] types to ignore
      # @param blk block to execute for every hit. Gets passed in the
      #     matching element itself.
      #
      # @example
      #   node.each_node(:send, [:mlhs]) do |call_node| .... end
      #   node.each_node(:lvar).any? { |it| it.var_name == 'something' }
      #   node.each_node([:block]).flat_map do |elem| ... end
      #
      # Returns an array with all matching nodes.
      def each_node(target_types, ignoring = [], &blk)
        return enum_for(:each_node, target_types, ignoring) unless blk

        look_for(Array(target_types), ignoring, &blk)
      end

      def contains_nested_node?(target_type)
        each_node(target_type).any?
      end

      # @quality :reek:DuplicateMethodCall { max_calls: 2 } is ok for lines.first
      # @quality :reek:FeatureEnvy
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

      # Method will be overridden by the code in the IfNode, CaseNode, and LogicOperatorBase sexp extensions.
      def condition; end

      protected

      # See ".each_node" for documentation.
      def look_for(target_types, ignoring, &blk)
        if target_types.include? type
          yield self
          return if ignoring.include?(type)
        end
        each_sexp do |elem|
          elem.look_for_recurse(target_types, ignoring, &blk)
        end
      end

      # See ".each_node" for documentation.
      def look_for_recurse(target_types, ignoring, &blk)
        yield self if target_types.include? type
        return if ignoring.include? type

        each_sexp do |elem|
          elem.look_for_recurse(target_types, ignoring, &blk)
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
