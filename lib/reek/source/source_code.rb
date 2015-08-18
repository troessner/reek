require_relative '../cli/silencer'
Reek::CLI::Silencer.silently do
  require 'parser/ruby22'
end
require_relative '../tree_dresser'
require_relative '../ast/node'

module Reek
  # @api private
  module Source
    #
    # A +Source+ object represents a chunk of Ruby source code.
    #
    # @api private
    class SourceCode
      IO_IDENTIFIER     = 'STDIN'
      STRING_IDENTIFIER = 'string'

      attr_reader :description

      # Initializer.
      #
      # code        - Ruby code as String
      # description - 'STDIN', 'string' or a filepath as String
      # parser      - the parser to use for generating AST's out of the given source
      def initialize(code, description, parser = Parser::Ruby22)
        @source      = code
        @description = description
        @parser      = parser
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
      def self.from(source)
        case source
        when File     then new(source.read, source.path)
        when IO       then new(source.readlines.join, IO_IDENTIFIER)
        when Pathname then new(source.read, source.to_s)
        when String   then new(source, STRING_IDENTIFIER)
        end
      end

      # Parses the given source into an AST and associates the source code comments with it.
      # This AST is then traversed by a TreeDresser which adorns the nodes in the AST
      # with our SexpExtensions.
      # Finally this AST is returned where each node is an anonymous subclass of Reek::AST::Node
      #
      # Important to note is that reek will not fail on unparseable files but rather print out
      # a warning and then just continue.
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
      #  @return [Anonymous subclass of Reek::AST::Node] the AST presentation
      #          for the given source
      def syntax_tree
        @syntax_tree ||=
          begin
            begin
              ast, comments = parser.parse_with_comments(source, description)
            rescue Racc::ParseError, Parser::SyntaxError => error
              $stderr.puts "#{description}: #{error.class.name}: #{error}"
            end

            # See https://whitequark.github.io/parser/Parser/Source/Comment/Associator.html
            comment_map = Parser::Source::Comment.associate(ast, comments) if ast
            TreeDresser.new.dress(ast, comment_map)
          end
      end

      private

      private_attr_reader :parser, :source
    end
  end
end
