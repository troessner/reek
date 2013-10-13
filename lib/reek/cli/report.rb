module Reek
  module Cli
    module ReportFormatter
      def self.format_list(warnings, formatter = SimpleWarningFormatter)
        warnings.map do |warning|
          "  #{formatter.format warning}"
        end.join("\n")
      end

      def self.header(examiner)
        count = examiner.smells_count
        result = "#{examiner.description} -- #{count} warning"
        result += 's' unless count == 1
        result
      end
    end

    module SimpleWarningFormatter
      def self.format(warning)
        "#{warning.context} #{warning.message} (#{warning.subclass})"
      end
    end

    module WarningFormatterWithLineNumbers
      def self.format(warning)
        "#{warning.lines.inspect}:#{SimpleWarningFormatter.format(warning)}"
      end
    end

    module SingleLineWarningFormatter
      def self.format(warning)
        "#{warning.source}:#{warning.lines.first}: #{SimpleWarningFormatter.format(warning)}"
      end
    end    

    #
    # A report that lists every source, including those that have no smells.
    #
    class VerboseReport
      def initialize(warning_formatter = SimpleWarningFormatter, report_formatter = ReportFormatter)
        @warning_formatter = warning_formatter
        @report_formatter = report_formatter
      end

      def report(examiner)
        result = @report_formatter.header examiner
        if examiner.smelly?
          formatted_list = @report_formatter.format_list examiner.smells, @warning_formatter
          result += ":\n#{formatted_list}"
        end
        result + "\n"
      end
    end

    #
    # A report that lists a section for each source that has smells.
    #
    class QuietReport < VerboseReport
      def report(examiner)
        if examiner.smelly?
          super
        else
          ''
        end
      end
    end
  end
end
