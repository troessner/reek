require 'set'
require 'reek/adapters/command_line'   # SMELL: Global Variable
require 'reek/masking_collection'

module Reek
  class ReportSection

    SMELL_FORMAT = '%m%c %w (%s)'

    def initialize(sniffer, display_masked_warnings)
      @cwarnings = MaskingCollection.new
      @desc = sniffer.desc
      @display_masked_warnings = display_masked_warnings  # SMELL: Control Couple
      sniffer.report_on(self)
    end

    def found_smell(warning)
      @cwarnings.add(warning)
      true
    end

    def found_masked_smell(warning)
      @cwarnings.add_masked(warning)
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report, with a heading.
    def verbose_report
      result = header
      result += ":\n#{smell_list}" if should_report
      result += "\n"
      result
    end

    def quiet_report
      return '' unless should_report
      # SMELL: duplicate knowledge of the header layout
      "#{header}:\n#{smell_list}\n"
    end

    def header
      "#{@desc} -- #{visible_header}#{masked_header}"
    end

    # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
    # this report.
    def smell_list
      result = []
      if @display_masked_warnings
        @cwarnings.each_item {|smell| result << "  #{smell.report(SMELL_FORMAT)}"}
      else
        @cwarnings.each_visible_item {|smell| result << "  #{smell.report(SMELL_FORMAT)}"}
      end
      result.join("\n")
    end

  private

    def should_report
      @cwarnings.num_visible_items > 0 or (@display_masked_warnings and @cwarnings.num_masked_items > 0)
    end

    def visible_header
      num_smells = @cwarnings.num_visible_items
      result = "#{num_smells} warning"
      result += 's' unless num_smells == 1
      result
    end

    def masked_header
      num_masked_warnings = @cwarnings.num_masked_items
      num_masked_warnings == 0 ? '' : " (+#{num_masked_warnings} masked)"
    end
  end

  class Report
    def initialize(sniffers, display_masked_warnings = false)
      @partials = Array(sniffers).map {|sn| ReportSection.new(sn, display_masked_warnings)}
    end
  end

  class VerboseReport < Report
    # SMELL: Implementation Inheritance
    def report
      @partials.map { |section| section.verbose_report }.join
    end
  end

  class QuietReport < Report
    # SMELL: Implementation Inheritance
    def report
      @partials.map { |section| section.quiet_report }.join
    end
  end
end
