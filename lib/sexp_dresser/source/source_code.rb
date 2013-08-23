require 'ruby_parser'
require 'sexp_dresser/source/config_file'
require 'sexp_dresser/source/tree_dresser'

module SexpDresser
  module Source

    #
    # A +Source+ object represents a chunk of Ruby source code.
    #
    class SourceCode

      @@err_io = $stderr

      class << self
        def err_io=(io)
          original = @@err_io
          @@err_io = io
          original
        end
      end

      attr_reader :desc

      def initialize(code, desc, parser = RubyParser.new)
        @source = code
        @desc = desc
        @parser = parser
      end

      def configure(analyzer) end

      def syntax_tree
        begin
          ast = @parser.parse(@source, @desc)
        rescue Exception => error
          @@err_io.puts "#{desc}: #{error.class.name}: #{error}"
        end
        ast ||= s()
        TreeDresser.new.dress(ast)
      end
    end
  end
end
