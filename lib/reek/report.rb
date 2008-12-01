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
      @smells = SortedSet.new
    end

    def <<(smell)  # :nodoc:
      @smells << smell
      true
    end
    
    def empty?  # :nodoc:
      @smells.empty?
    end

    def length  # :nodoc:
      @smells.length
    end

    def [](index)  # :nodoc:
      @smells.to_a[index]
    end

    # Creates a formatted report of all the smells recorded in
    # this report.
    def to_s
      @smells.map {|smell| smell.report}.join("\n")
    end
  end

end