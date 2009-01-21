$:.unshift File.dirname(__FILE__)

require 'set'

module Reek

  class SortByContext
    def self.compare(smell1, smell2)
      smell1.detailed_report <=> smell2.detailed_report
    end
  end

  class SortBySmell
    def self.compare(smell1, smell2)
      smell1.report <=> smell2.report
    end
  end

  class Report

    SORT_ORDERS = {
      :context => SortByContext,
      :smell => SortBySmell
    }

    def initialize  # :nodoc:
      @report = SortedSet.new
    end

    def <<(smell)  # :nodoc:
      @report << smell
      true
    end
    
    def empty?  # :nodoc:
      @report.empty?
    end

    def length  # :nodoc:
      @report.length
    end
    
    alias size length

    def [](index)  # :nodoc:
      @report.to_a[index]
    end

    # Creates a formatted report of all the smells recorded in
    # this report.
    def to_s
      @report.map {|smell| smell.report}.join("\n")
    end
  end

end