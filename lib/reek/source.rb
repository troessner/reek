require 'reek/sniffer'

module Reek

  #
  # A +Source+ object represents a chunk of Ruby source code.
  #
  # The various class methods are factories that will create +Source+
  # instances from various types of input.
  #
  class Source

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # the +IO+ stream. The stream is consumed upto end-of-file, but the
    # source code is not parsed until +report+ is called. +desc+ provides
    # a string description to be used in the header of formatted reports.
    #
    def self.from_io(ios, desc)
      code = ios.readlines.join
      return new(code, desc)
    end

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # the +code+ string. The code is not parsed until +report+ is called.
    #
    def self.from_s(code)
      return new(code, 'string')
    end

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # the named file. The source code is not parsed until +report+ is called.
    #
    def self.from_path(filename)
      code = IO.readlines(filename).join
      # SMELL: Greedy Method
      # Someone else should create the Sniffer; the Sniffer should then ask
      # this source to configure it.
      sniffer = Sniffer.new.configure_along_path(filename)
      return new(code, filename, sniffer)
    end

    attr_reader :desc
    attr_reader :sniffer          # SMELL

    def initialize(code, desc, sniffer = Sniffer.new)     # :nodoc:
      @source = code
      @desc = desc
      @sniffer = sniffer
      @sniffer.source = self
    end

    def generate_syntax_tree
      RubyParser.new.parse(@source, @desc) || s()
    end
  end
end

# SMELL: Runaway Dependencies
# Surely this should only be required from reek/spec ?
require 'reek/object_source'
