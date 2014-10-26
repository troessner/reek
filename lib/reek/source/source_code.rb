require 'ruby_parser'
require 'reek/source/config_file'
require 'reek/source/tree_dresser'

module Reek
  module Source
    #
    # A +Source+ object represents a chunk of Ruby source code.
    #
    class SourceCode
      attr_reader :desc

      def initialize(code, desc, parser = RubyParser.new)
        @source = code
        @desc = desc
        @parser = parser
      end

      def relevant_config_files
        []
      end

      def syntax_tree
        begin
          ast = @parser.parse(@source, @desc)
        rescue Racc::ParseError, RubyParser::SyntaxError => error
          $stderr.puts "#{desc}: #{error.class.name}: #{error}"
        end
        ast ||= s()
        TreeDresser.new.dress(ast)
      end
    end
  end
end
