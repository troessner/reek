require 'set'
require 'reek/sniffer'

module Reek
  class Report
    include Enumerable

    def initialize(sniffer)  # :nodoc:
      @masked_warnings = SortedSet.new
      @warnings = SortedSet.new
      @desc = sniffer.desc
      sniffer.report_on(self)
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
    def full_report
      return quiet_report if Options[:quiet]
      result = header(@warnings.length)
      result += ":\n#{smell_list}" if should_report
      result += "\n"
      result
    end

    def quiet_report
      return '' unless should_report
      "#{header(@warnings.length)}:\n#{smell_list}\n"
    end

    def should_report
      @warnings.length > 0 or (Options[:show_all] and @masked_warnings.length > 0)
    end

    def header(num_smells)
      result = "#{@desc} -- #{num_smells} warning"
      result += 's' unless num_smells == 1
      result += " (+#{@masked_warnings.length} masked)" unless @masked_warnings.empty?
      result
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def smell_list
      all = SortedSet.new(@warnings)
      all.merge(@masked_warnings) if Options[:show_all]
      all.map {|smell| "  #{smell.report}"}.join("\n")
    end
  end

  class ReportList
    include Enumerable

    def initialize(sniffers)
      @sniffers = sniffers
    end

    def empty?
      length == 0
    end

    def length
      @sniffers.inject(0) {|sum, sniffer| sum + sniffer.num_smells }
    end

    # SMELL: Shotgun Surgery
    # This method and the next will have to be repeated for every new
    # kind of report.
    def full_report
      @sniffers.map { |sniffer| sniffer.full_report }.join
    end

    def quiet_report
      @sniffers.map { |sniffer| sniffer.quiet_report }.join
    end

    #
    # Checks this report for instances of +smell_class+, and returns +true+
    # only if one of them has a report string matching all of the +patterns+.
    #
    def has_smell?(smell_class, patterns)
      @sniffers.any? { |sniffer| sniffer.has_smell?(smell_class, patterns) }
    end
  end
end
