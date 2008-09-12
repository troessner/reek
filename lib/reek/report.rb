$:.unshift File.dirname(__FILE__)

require 'set'

module Reek

  class SortByContext
    def compare(smell1, smell2)
      smell1.detailed_report <=> smell2.detailed_report
    end
  end

  class SortBySmell
    def compare(smell1, smell2)
      smell1.report <=> smell2.report
    end
  end

  class Report

    SORT_ORDERS = {
      :context => SortByContext.new,
      :smell => SortBySmell.new
    }

    def initialize  # :nodoc:
      @smells = SortedSet.new
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
      @smells.to_a[i]
    end

    # Creates a formatted report of all the smells recorded in
    # this report.
    def to_s
      @smells.map {|smell| smell.report}.join("\n")
    end
  end

end