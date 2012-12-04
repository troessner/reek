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

      # At runtime, reek tries to load ripper_ruby_parser. If that succeeds,
      # reek uses that parser and will be able to handle Ruby 1.9 syntax. On
      # Ruby versions below 1.9.3, it will fail and reek will use ruby_parser
      # and handle Ruby 1.8 syntax only.
      PARSER_CLASS = begin
                       require 'ripper_ruby_parser'
                       RipperRubyParser::Parser
                     rescue LoadError
                       require 'ruby_parser'
                       RubyParser
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
