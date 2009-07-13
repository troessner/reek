require 'reek/sniffer'

module Reek

  #
  # A +Source+ object represents a chunk of Ruby source code.
  #
  class Source

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # the named file. The source code is not parsed until +report+ is called.
    #
    def self.from_path(filename, sniffer)
      code = IO.readlines(filename).join
      # SMELL: Greedy Method
      # The Sniffer should ask this source to configure it.
      sniffer.configure_along_path(filename)
      return new(code, filename, sniffer)
    end

    attr_reader :desc
    attr_reader :sniffer          # SMELL -- bidirectional link

    def initialize(code, desc, sniffer)     # :nodoc:
      @source = code
      @desc = desc
      @sniffer = sniffer
      @sniffer.source = self
    end

    def syntax_tree
      RubyParser.new.parse(@source, @desc) || s()
    end
  end
end
