require 'reek/sniffer'

module Reek

  #
  # A +Source+ object represents a chunk of Ruby source code.
  #
  class Source

    attr_reader :desc
    attr_reader :sniffer          # SMELL -- bidirectional link

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

    attr_reader :desc
    attr_reader :sniffer          # SMELL -- bidirectional link

    def initialize(file)
      @file = file
      super(@file.lines.to_a.join, @file.path)
    end

    def configure(sniffer)
      sniffer.configure_along_path(@file.path)
    end
  end
end
