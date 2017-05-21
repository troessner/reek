# frozen_string_literal: true

require_relative '../cli/silencer'
Reek::CLI::Silencer.silently do
  require 'parser/ruby24'
end
require_relative '../tree_dresser'
require_relative '../ast/node'
require_relative '../ast/builder'

# Opt in to new way of representing lambdas
Parser::Builders::Default.emit_lambda = true

module Reek
  module Source
    #
    # A +Source+ object represents a chunk of Ruby source code.
    #
    class SourceCode
      IO_IDENTIFIER     = 'STDIN'.freeze
      STRING_IDENTIFIER = 'string'.freeze

      attr_reader :origin, :diagnostics, :syntax_tree

      # Initializer.
      #
      # code   - Ruby code as String
      # origin - 'STDIN', 'string' or a filepath as String
      # parser - the parser to use for generating AST's out of the given source
      def initialize(code:, origin:, parser: default_parser)
        @origin = origin
        @diagnostics = []
        @syntax_tree = parse(parser, code)
      end

      # Initializes an instance of SourceCode given a source.
      # This source can come via 4 different ways:
      # - from Files or Pathnames a la `reek lib/reek/`
      # - from IO (STDIN) a la `echo "class Foo; end" | reek`
      # - from String via our rspec matchers a la `expect("class Foo; end").to reek`
      #
      # @param source [File|IO|String] - the given source
      #
      # @return an instance of SourceCode
      # :reek:DuplicateMethodCall: { max_calls: 2 }
      def self.from(source)
        case source
        when File     then new(code: source.read,           origin: source.path)
        when IO       then new(code: source.readlines.join, origin: IO_IDENTIFIER)
        when Pathname then new(code: source.read,           origin: source.to_s)
        when String   then new(code: source,                origin: STRING_IDENTIFIER)
        end
      end

      # @return [true|false] Returns true if parsed file does not have any syntax errors.
      def valid_syntax?
        @diagnostics.none? { |diagnostic| [:error, :fatal].include?(diagnostic.level) }
      end

      private

      attr_reader :source

      # Parses the given source into an AST and associates the source code comments with it.
      # This AST is then traversed by a TreeDresser which adorns the nodes in the AST
      # with our SexpExtensions.
      # Finally this AST is returned where each node is an anonymous subclass of Reek::AST::Node
      #
      # Important to note is that Reek will not fail on unparseable files but rather register a
      # parse error to @diagnostics and then just continue.
      #
      # Given this @source:
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
      # @param parser [Parser::Ruby24]
      # @param source [String] - Ruby code
      # @return [Anonymous subclass of Reek::AST::Node] the AST presentation
      #         for the given source
      def parse(parser, source)
        buffer = Parser::Source::Buffer.new(origin, 1)
        buffer.source = source
        begin
          ast, comments = parser.parse_with_comments(buffer)
        rescue Parser::SyntaxError # rubocop:disable Lint/HandleExceptions
          # All errors are in diagnostics. No need to handle exception.
        end

        # See https://whitequark.github.io/parser/Parser/Source/Comment/Associator.html
        comment_map = Parser::Source::Comment.associate(ast, comments) if ast
        TreeDresser.new.dress(ast, comment_map)
      end

      # :reek:TooManyStatements: { max_statements: 6 }
      # :reek:FeatureEnvy
      def default_parser
        Parser::Ruby24.new(AST::Builder.new).tap do |parser|
          diagnostics = parser.diagnostics
          diagnostics.all_errors_are_fatal = false
          diagnostics.ignore_warnings      = false
          diagnostics.consumer = lambda do |diagnostic|
            @diagnostics << diagnostic
          end
        end
      end
    end
  end
end
