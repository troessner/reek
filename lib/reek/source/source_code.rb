if RUBY_VERSION < "1.9.3"
  require 'ruby_parser'
else
  require 'ripper_ruby_parser'
end
require File.join(File.dirname(File.expand_path(__FILE__)), 'config_file')
require File.join(File.dirname(File.expand_path(__FILE__)), 'tree_dresser')

module Reek
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

      PARSER_CLASS = if RUBY_VERSION < "1.9.3"
                       RubyParser
                     else
                       RipperRubyParser::Parser
                     end

      def initialize(code, desc, parser = PARSER_CLASS.new)
        @source = code
        @desc = desc
        @parser = parser
      end

      def configure(sniffer) end

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
