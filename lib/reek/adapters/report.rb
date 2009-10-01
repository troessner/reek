require 'set'
require 'reek/adapters/command_line'   # SMELL: Global Variable

module Reek
  class ReportSection

    def initialize(sniffer, display_masked_warnings, format)  # :nodoc:
      @format = format
      @masked_warnings = SortedSet.new
      @warnings = SortedSet.new
      @desc = sniffer.desc
      @display_masked_warnings = display_masked_warnings
      sniffer.report_on(self)
    end

    def <<(smell)  # :nodoc:
      @warnings << smell
      true
    end

    def record_masked_smell(smell)
      @masked_warnings << smell
    end

    def num_masked_smells       # SMELL: getter
      @masked_warnings.length
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report, with a heading.
    def full_report
      result = header
      result += ":\n#{smell_list}" if should_report
      result += "\n"
      result
    end

    def quiet_report
      return '' unless should_report
      "#{header}:\n#{smell_list}\n"
    end

    def header
      @all_warnings = SortedSet.new(@warnings)      # SMELL: Temporary Field
      @all_warnings.merge(@masked_warnings)
      "#{@desc} -- #{visible_header}#{masked_header}"
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def smell_list
      smells = @display_masked_warnings ? @all_warnings : @warnings
      smells.map {|smell| "  #{smell.report(@format)}"}.join("\n")
    end

  private

    def should_report
      @warnings.length > 0 or (@display_masked_warnings and @masked_warnings.length > 0)
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
  end

  class Report
    def initialize(sniffers, format, display_masked_warnings = false)
      @partials = Array(sniffers).map {|sn| ReportSection.new(sn, display_masked_warnings, format)}
    end
  end

  class FullReport < Report
    def report
      @partials.map { |rpt| rpt.full_report }.join
    end
  end

  class QuietReport < Report
    def report
      @partials.map { |rpt| rpt.quiet_report }.join
    end
  end
end
