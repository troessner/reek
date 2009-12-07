require 'reek/adapters/source'

module Reek

  #
  # Represents a file of Ruby source, whose contents will be examined
  # for code smells.
  #
  class SourceFile < Source

    def initialize(file)
      @file = file
      super(IO.readlines(@file.path).join, @file.path)
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
