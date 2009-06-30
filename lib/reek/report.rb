require 'set'
require 'reek/sniffer'
require 'reek/smells/smell_detector'

module Reek
  class Report
    include Enumerable

    def initialize(sniffer = nil)  # :nodoc:
      @masked_smells = SortedSet.new
      @report = SortedSet.new
      sniffer.report_on(self) if sniffer
    end

    #
    # Yields, in turn, each SmellWarning in this report.
    #
    def each
      @report.each { |smell| yield smell }
    end

    #
    # Checks this report for instances of +smell_class+, and returns +true+
    # only if one of them has a report string matching all of the +patterns+.
    #
    def has_smell?(smell_class, patterns)
      @report.any? { |smell| smell.matches?(smell_class, patterns) }
    end

    def <<(smell)  # :nodoc:
      @report << smell
      true
    end

    def record_masked_smell(smell)
      @masked_smells << smell
    end

    def num_masked_smells
      @masked_smells.length
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
      result = header(desc, @report.length)
      result += ":\n#{to_s}\n" if length > 0
      result
    end

    def header(desc, num_smells)
      result = "#{desc} -- #{num_smells} warning"
      result += 's' unless num_smells == 1
      result += " (+#{@masked_smells.length} masked)" unless @masked_smells.empty?
      result
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def to_s
      @report.map {|smell| "  #{smell.report}"}.join("\n")
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

    def full_report
      @sources.map { |src| src.full_report }.join
    end

    #
    # Checks this report for instances of +smell_class+, and returns +true+
    # only if one of them has a report string matching all of the +patterns+.
    #
    def has_smell?(smell_class, patterns)
      @sources.any? { |smell| smell.has_smell?(smell_class, patterns) }
    end
  end
end
