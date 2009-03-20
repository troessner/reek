require 'reek/code_parser'

module Reek
  class Source
    def initialize(filename)
      if File.exists?(filename)
        @source = IO.readlines(filename).join
        @dir = File.dirname(filename)
        @filename = filename
      else
        @source = filename
        @dir = '.'
        @filename = "source code"
      end
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
      @filename
    end
  end
end
