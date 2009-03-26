require 'set'
require 'reek/smells/smell_detector'

module Reek
  class Report
    include Enumerable

    def initialize  # :nodoc:
      @report = SortedSet.new
    end

    def each
      @report.each { |smell| yield smell }
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

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def to_s
      @report.map {|smell| smell.report}.join("\n")
    end
  end

end