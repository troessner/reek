require 'set'
require 'reek/smells/smell_detector'

module Reek
  class Report
    include Enumerable

    def initialize  # :nodoc:
      @report = SortedSet.new
    end

    #
    # Yields, in turn, each SmellWarning in this report.
    #
    def each
      @report.each { |smell| yield smell }
    end

    def <<(smell)  # :nodoc:
      @report << smell
      true
    end
    
    def empty?
      @report.empty?
    end

    def length
      @report.length
    end
    
    alias size length

    def [](index)  # :nodoc:
      @report.to_a[index]
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report, with a heading.
    def full_report(desc)
      "\"#{desc}\" -- #{length} warnings:\n#{to_s}\n"
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def to_s
      @report.map {|smell| smell.report}.join("\n")
    end
  end

  class ReportList
    include Enumerable

    def initialize(sources)
      @sources = sources
    end

    #
    # Yields, in turn, each SmellWarning in every report in this report.
    #
    def each(&blk)
      @sources.each {|src| src.report.each(&blk) }
    end

    def empty?
      length == 0
    end

    def length
      @sources.inject(0) {|sum, src| sum + src.report.length }
    end

    def smelly_sources
      @sources.select {|src| src.smelly? }
    end

    def to_s
      smelly_sources.map { |src| src.full_report }.join("\n")
    end
  end
end