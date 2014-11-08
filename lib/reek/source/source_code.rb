old_verbose, $VERBOSE = $VERBOSE, nil
require 'parser/current'
$VERBOSE = old_verbose
require 'reek/source/config_file'
require 'reek/source/tree_dresser'
require 'reek/source/ast_node'

module Reek
  module Source
    #
    # A +Source+ object represents a chunk of Ruby source code.
    #
    class SourceCode
      attr_reader :desc

      def initialize(code, desc, parser = Parser::Ruby21.new)
        @source = code
        @desc = desc
        @parser = parser
      end

      def relevant_config_files
        []
      end

      def syntax_tree
        @syntax_tree ||=
          begin
            buffer = Parser::Source::Buffer.new(@desc)
            buffer.source = @source

            begin
              ast, comments = @parser.parse_with_comments(buffer)
            rescue Racc::ParseError, Parser::SyntaxError => error
              $stderr.puts "#{desc}: #{error.class.name}: #{error}"
            end
            ast ||= AstNode.new(:empty)
            comments ||= []

            comment_map = Parser::Source::Comment.associate(ast, comments)
            TreeDresser.new.dress(ast, comment_map)
          end
      end
    end
  end
end
