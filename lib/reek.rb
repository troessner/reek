$:.unshift File.dirname(__FILE__)

require 'reek/code_parser'
require 'reek/report'

module Reek # :doc:

  #
  # Analyse the given source, looking for code smells.
  # The source can be a filename or a String containing Ruby code.
  # Returns a +Report+ listing the smells found.
  #
  class Analyser
    def initialize(src)
      @source = src
    end
    
    #
    # Returns a +Report+ listing the smells found.
    #
    def analyse
      report = Report.new
      config = SmellConfig.new
      if File.exists?(@source)
        source = IO.readlines(@source).join
        config.load_local(@source)
      else
        source = @source
      end
      smells = config.smell_listeners
      CodeParser.new(report, smells).check_source(source)
      report
    end
  end
end
