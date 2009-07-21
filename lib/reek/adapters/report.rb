require 'set'
require 'reek/adapters/command_line'

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
      result = header
      result += ":\n#{smell_list}" if should_report
      result += "\n"
      result
    end

    def quiet_report
      return '' unless should_report
      "#{header}:\n#{smell_list}\n"
    end

    def should_report
      @warnings.length > 0 or (Options[:show_all] and @masked_warnings.length > 0)
    end

    def header
      @all_warnings = SortedSet.new(@warnings)      # SMELL: Temporary Field
      @all_warnings.merge(@masked_warnings)
      "#{@desc} -- #{visible_header}#{masked_header}"
    end

    def visible_header
      num_smells = @warnings.length
      result = "#{num_smells} warning"
      result += 's' unless num_smells == 1
      result
    end

    def masked_header
      num_masked_warnings = @all_warnings.length - @warnings.length
      num_masked_warnings == 0 ? '' : " (+#{num_masked_warnings} masked)"
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def smell_list
      smells = Options[:show_all] ? @all_warnings : @warnings
      smells.map {|smell| "  #{smell.report}"}.join("\n")
    end
  end

  class ReportList
    include Enumerable

    def initialize(sniffers)
      @sniffers = sniffers
      @partials = sniffers.map {|sn| Report.new(sn)}
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
      @partials.map { |rpt| rpt.full_report }.join
    end

    def quiet_report
      @partials.map { |rpt| rpt.quiet_report }.join
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
