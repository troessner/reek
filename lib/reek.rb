$:.unshift File.dirname(__FILE__)

require 'reek/code_parser'
require 'reek/report'

module Reek # :doc:
  
  VERSION = '0.3.1.1'

  #
  # Analyse the given source, looking for code smells.
  # The source can be a filename or a String containing Ruby code.
  # Returns a +Report+ listing the smells found.
  #
  class Analyser
    def initialize(src)
      @source = src
      @config = SmellConfig.new
      src.configure(@config)
    end
    
    #
    # Returns a +Report+ listing the smells found.
    #
    def analyse
      report = Report.new
      smells = @config.smell_listeners
      CodeParser.new(report, smells).check_source(@source.source)
      report
    end
  end
end
