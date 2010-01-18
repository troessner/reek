require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'masking_collection')

module Reek
  module Cli

    #
    # A section of a text report; has a heading that identifies the source
    # and summarises the smell counts, and a body listing details of all
    # smells found.
    #
    class ReportSection

      SMELL_FORMAT = '%m%c %w (%s)'

      def initialize(examiner, display_masked_warnings)
        @examiner = examiner
        @display_masked_warnings = display_masked_warnings  # SMELL: Control Couple
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
        "#{@examiner.description} -- #{visible_header}#{masked_header}"
      end

      # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
      # this report.
      def smell_list
        if @display_masked_warnings
          result = @examiner.all_smells.map {|smell| "  #{smell.report(SMELL_FORMAT)}"}
        else
          result = @examiner.all_active_smells.map {|smell| "  #{smell.report(SMELL_FORMAT)}"}
        end
        result.join("\n")
      end

    private

      def should_report
        @examiner.num_active_smells > 0 or (@display_masked_warnings and @examiner.num_masked_smells > 0)
      end

      def visible_header
        num_smells = @examiner.all_active_smells.length
        result = "#{num_smells} warning"
        result += 's' unless num_smells == 1
        result
      end

      def masked_header
        num_masked_warnings = @examiner.num_masked_smells
        num_masked_warnings == 0 ? '' : " (+#{num_masked_warnings} masked)"
      end
    end

    #
    # A report that lists every source, including those that have no smells.
    #
    class VerboseReport
      def initialize(examiner, display_masked_warnings)
        @reporter = ReportSection.new(examiner, display_masked_warnings)
      end
      def report
        @reporter.verbose_report
      end
    end

    #
    # A report that lists a section for each source that has smells.
    #
    class QuietReport
      def initialize(examiner, display_masked_warnings)
        @reporter = ReportSection.new(examiner, display_masked_warnings)
      end
      def report
        @reporter.quiet_report
      end
    end
  end
end
