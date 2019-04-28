# frozen_string_literal: true

require_relative '../cli/silencer'
# Silence Parser's warnings about Ruby micro version differences
Reek::CLI::Silencer.silently { require 'parser/current' }
require_relative '../tree_dresser'
require_relative '../ast/node'
require_relative '../ast/builder'

# Opt in to new way of representing lambdas
Reek::AST::Builder.emit_lambda = true

module Reek
  module Source
    #
    # A +SourceCode+ object represents a chunk of Ruby source code.
    #
    class SourceCode
      IO_IDENTIFIER     = 'STDIN'
      STRING_IDENTIFIER = 'string'

      # Initializer.
      #
      # @param source [File|Pathname|IO|String] Ruby source code
      # @param origin [String] Origin of the source code. Will be determined
      #   automatically if left blank.
      # @param parser the parser to use for generating AST's out of the given code
      def initialize(source:, origin: nil, parser: self.class.default_parser)
        @origin = origin
        @parser = parser
        @source = source
      end

      # Initializes an instance of SourceCode given a source.
      # This source can come via several different ways:
      # - from Files or Pathnames a la `reek lib/reek/`
      # - from IO (STDIN) a la `echo "class Foo; end" | reek`
      # - from String via our rspec matchers a la `expect("class Foo; end").to reek`
      # - from an existing SourceCode object. This is passed through unchanged
      #
      # @param source [SourceCode|File|Pathname|IO|String] the given source
      # @param origin [String|nil]
      #
      # @return an instance of SourceCode
      def self.from(source, origin: nil)
        case source
        when self then source
        else new(source: source, origin: origin)
        end
      end

      def syntax_tree
        @syntax_tree ||= parse
      end

      def self.default_parser
        Parser::CurrentRuby.new(AST::Builder.new).tap do |parser|
          diagnostics = parser.diagnostics
          diagnostics.all_errors_are_fatal = true
          diagnostics.ignore_warnings      = true
        end
      end

      def origin
        @origin ||=
          case source
          when File     then source.path
          when IO       then IO_IDENTIFIER
          when Pathname then source.to_s
          when String   then STRING_IDENTIFIER
          end
      end

      private

      def code
        @code ||=
          case source
          when File, Pathname then source.read
          when IO             then source.readlines.join
          when String         then source
          end.force_encoding(Encoding::UTF_8)
      end

      attr_reader :parser, :source

      # Parses the given code into an AST and associates the source code comments with it.
      # This AST is then traversed by a TreeDresser which adorns the nodes in the AST
      # with our SexpExtensions.
      # Finally this AST is returned where each node is an anonymous subclass of Reek::AST::Node
      #
      # Given this @code:
      #
      #   # comment about C
      #   class C
      #     def m
      #       puts 'nada'
      #     end
      #   end
      #
      # this method would return something that looks like
      #
      #   (class
      #     (const nil :C) nil
      #     (def :m
      #       (args)
      #       (send nil :puts
      #         (str "nada"))))
      #
      # where each node is possibly adorned with our SexpExtensions (see ast/ast_node_class_map
      # and ast/sexp_extensions for details).
      #
      # @return Reek::AST::Node the AST presentation for the given code
      def parse
        buffer = Parser::Source::Buffer.new(origin, 1)
        buffer.source = code
        ast, comments = parser.parse_with_comments(buffer)

        # See https://whitequark.github.io/parser/Parser/Source/Comment/Associator.html
        comment_map = Parser::Source::Comment.associate(ast, comments)
        TreeDresser.new.dress(ast, comment_map) || AST::Node.new(:empty)
      end
    end
  end
end
