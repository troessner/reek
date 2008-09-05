$:.unshift File.dirname(__FILE__)

module Reek

  class Report
    def initialize
      @smells = []
    end

    def <<(smell)
      @smells << smell
    end
    
    def empty?
      @smells.empty?
    end
    
    def length
      @smells.length
    end
    
    def [](i)
      @smells[i]
    end

    def to_s
      @smells.map {|smell| smell.report}.join("\n")
    end
  end
end