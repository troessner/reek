$:.unshift File.dirname(__FILE__)

module Reek

  class Report
    def initialize  # :nodoc:
      @smells = []
    end

    def <<(smell)  # :nodoc:
      @smells << smell
    end
    
    def empty?  # :nodoc:
      @smells.empty?
    end
    
    def length  # :nodoc:
      @smells.length
    end
    
    def [](i)  # :nodoc:
      @smells[i]
    end

    # Creates a formatted report of all the smells recorded in
    # this report.
    def to_s
      @smells.map {|smell| smell.report}.join("\n")
    end
  end
end