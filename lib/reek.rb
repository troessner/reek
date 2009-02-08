$:.unshift File.dirname(__FILE__)

require 'reek/code_parser'
require 'reek/report'

module Reek # :doc:
  
  VERSION = '0.3.99'

  #
  # Analyse the given source, looking for code smells.
  # The source can be a filename or a String containing Ruby code.
  # Returns a +Report+ listing the smells found.
  #
  class Analyser
    def initialize(src)
      @config = SmellConfig.new
      if File.exists?(src)
        @source = IO.readlines(src).join
        @config.load_local(src)
      else
        @source = src
      end
    end
    
    #
    # Returns a +Report+ listing the smells found.
    #
    def analyse
      report = Report.new
      smells = @config.smell_listeners
      CodeParser.new(report, smells).check_source(@source)
      report
    end
  end
end
