require 'reek/adapters/config_file'
require 'reek/tree_dresser'

module Reek

  #
  # A +Source+ object represents a chunk of Ruby source code.
  #
  class Source

    attr_reader :desc

    def initialize(code, desc)
      @source = code
      @desc = desc
    end

    def configure(sniffer) end

    def syntax_tree
      ast = RubyParser.new.parse(@source, @desc) || s()
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
