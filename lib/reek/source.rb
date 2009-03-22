require 'reek/code_parser'

module Reek
  class Source
    def self.from_io(ios, desc)
      code = ios.readlines.join
      return new(code, desc)
    end

    def self.from_s(code)
      return new(code, 'string')
    end

    def self.from_f(filename)
      code = IO.readlines(filename).join
      return new(code, filename, File.dirname(filename))
    end

    def initialize(code, desc, dir = '.')
      @source = code
      @dir = dir
      @desc = desc
    end

    #
    # Analyse the given source, looking for code smells.
    # The source can be a filename or a String containing Ruby code.
    # Returns a +Report+ listing the smells found.
    #
    def analyse
      report = Report.new
      smells = SmellConfig.new.load_local(@dir).smell_listeners
      CodeParser.new(report, smells).check_source(@source)
      report
    end

    def to_s
      @desc
    end
  end
end
