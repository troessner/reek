old_verbose, $VERBOSE = $VERBOSE, nil
require 'parser/current'
$VERBOSE = old_verbose
require_relative '../core/tree_dresser'
require_relative '../core/ast_node'

module Reek
  module Source
    #
    # A +Source+ object represents a chunk of Ruby source code.
    #
    class SourceCode
      attr_reader :desc

      def initialize(code, desc, parser = Parser::Ruby21)
        @source = code
        @desc = desc
        @parser = parser
      end

      def self.from(source)
        case source
        when File   then new(source.read, source.path)
        when IO     then new(source.readlines.join, 'STDIN')
        when String then new(source, 'string')
        end
      end

      def syntax_tree
        @syntax_tree ||=
          begin
            begin
              ast, comments = @parser.parse_with_comments(@source, @desc)
            rescue Racc::ParseError, Parser::SyntaxError => error
              $stderr.puts "#{desc}: #{error.class.name}: #{error}"
            end

            comment_map = Parser::Source::Comment.associate(ast, comments) if ast
            Core::TreeDresser.new.dress(ast, comment_map)
          end
      end
    end
  end
end
