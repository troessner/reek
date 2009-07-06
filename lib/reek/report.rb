require 'set'
require 'reek/sniffer'
require 'reek/smells/smell_detector'

module Reek
  class Report
    include Enumerable

    def initialize(sniffer = nil)  # :nodoc:
      @masked_warnings = SortedSet.new
      @warnings = SortedSet.new
      sniffer.report_on(self) if sniffer
    end

    #
    # Yields, in turn, each SmellWarning in this report.
    #
    def each
      @warnings.each { |smell| yield smell }
    end

    #
    # Checks this report for instances of +smell_class+, and returns +true+
    # only if one of them has a report string matching all of the +patterns+.
    #
    def has_smell?(smell_class, patterns)
      @warnings.any? { |smell| smell.matches?(smell_class, patterns) }
    end

    def <<(smell)  # :nodoc:
      @warnings << smell
      true
    end

    def record_masked_smell(smell)
      @masked_warnings << smell
    end

    def num_masked_smells
      @masked_warnings.length
    end
    
    def empty?
      @warnings.empty?
    end

    def length
      @warnings.length
    end
    
    alias size length

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report, with a heading.
    def full_report(desc)
      result = header(desc, @warnings.length)
      result += ":\n#{to_s}" if should_report
      result += "\n"
      result
    end

    def should_report
      @warnings.length > 0 or (Options[:show_all] and @masked_warnings.length > 0)
    end

    def header(desc, num_smells)
      result = "#{desc} -- #{num_smells} warning"
      result += 's' unless num_smells == 1
      result += " (+#{@masked_warnings.length} masked)" unless @masked_warnings.empty?
      result
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def to_s
      all = SortedSet.new(@warnings)
      all.merge(@masked_warnings) if Options[:show_all]
      all.map {|smell| "  #{smell.report}"}.join("\n")
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
