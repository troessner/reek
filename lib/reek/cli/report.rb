module Reek
  module Cli

    #
    # A section of a text report; has a heading that identifies the source
    # and summarises the smell counts, and a body listing details of all
    # smells found.
    #
    class ReportSection

      SMELL_FORMAT = '%m%c %w (%s)'

      def initialize(examiner)
        @examiner = examiner
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
        "#{@examiner.description} -- #{visible_header}"
      end

      # Creates a formatted report of all the +Smells::SmellWarning+ objects recorded in
      # this report.
      def smell_list
        @examiner.smells.map {|smell| "  #{smell.report(SMELL_FORMAT)}"}.join("\n")
      end

    private

      def should_report
        @examiner.num_smells > 0
      end

      def visible_header
        num_smells = @examiner.smells.length
        result = "#{num_smells} warning"
        result += 's' unless num_smells == 1
        result
      end
    end

    #
    # A report that lists every source, including those that have no smells.
    #
    class VerboseReport
      def initialize(examiner)
        @reporter = ReportSection.new(examiner)
      end
      def report
        @reporter.verbose_report
      end
    end

    #
    # A report that lists a section for each source that has smells.
    #
    class QuietReport
      def initialize(examiner)
        @reporter = ReportSection.new(examiner)
      end
      def report
        @reporter.quiet_report
      end
    end
  end
end
