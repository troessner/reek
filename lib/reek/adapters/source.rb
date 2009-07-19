require 'reek/sniffer'

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
      RubyParser.new.parse(@source, @desc) || s()
    end
  end

  #
  # Represents a file of Ruby source, whose contents will be examined
  # for code smells.
  #
  class SourceFile < Source

    def initialize(file)
      @file = file
      super(@file.lines.to_a.join, @file.path)
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
