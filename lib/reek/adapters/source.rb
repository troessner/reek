require 'ruby_parser'
require 'reek/adapters/config_file'
require 'reek/tree_dresser'

module Reek

  #
  # A +Source+ object represents a chunk of Ruby source code.
  #
  class Source

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

  #
  # Represents a file of Ruby source, whose contents will be examined
  # for code smells.
  #
  class SourceFile < Source

    def self.lines(file)
      IO.readlines(file.path)
    end

    def initialize(file)
      @file = file
      super(SourceFile.lines(@file).join, @file.path)
    end

    def configure(sniffer)
      path = File.expand_path(File.dirname(@file.path))
      all_config_files(path).each { |cf| ConfigFile.new(cf).configure(sniffer) }
    end

  private

    def all_config_files(path)
      return [] unless File.exist?(path)
      parent = File.dirname(path)
      return [] if path == parent
      all_config_files(parent) + Dir["#{path}/*.reek"]
    end
  end
end
