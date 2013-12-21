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

    class Report
      def initialize(warning_formatter = SimpleWarningFormatter, report_formatter = ReportFormatter, sort_by_issue_count = false)
        @warning_formatter   = warning_formatter
        @report_formatter    = report_formatter
        @examiners           = []
        @total_smell_count   = 0
        @sort_by_issue_count = sort_by_issue_count
      end

      def add_examiner(examiner)
        @total_smell_count += examiner.smells_count
        @examiners << examiner
        self
      end

      def show
        sort_examiners
        display_summary
        display_total_smell_count
      end

      def has_smells?
        @total_smell_count > 0
      end

    private

      def sort_examiners
        @examiners.sort! {|a, b| b.smells_count <=> a.smells_count } if @sort_by_issue_count
      end

      def display_summary
        print gather_results.reject(&:empty?).join("\n")
      end

      def display_total_smell_count
        if @examiners.size > 1
          print "\n"
          print total_smell_count_message
        end
      end

      def total_smell_count_message
        "#{@total_smell_count} total warning#{'s' unless @total_smell_count == 1 }\n"
      end

      def summarize_single_examiner(examiner)
        result = @report_formatter.header examiner
        if examiner.smelly?
          formatted_list = @report_formatter.format_list examiner.smells, @warning_formatter
          result += ":\n#{formatted_list}"
        end
        result
      end
    end

    class VerboseReport < Report
      def gather_results
        @examiners.each_with_object([]) do |examiner, result|
          result << summarize_single_examiner(examiner)
        end
      end
    end

    class QuietReport < Report
      def gather_results
        @examiners.each_with_object([]) do |examiner, result|
          if examiner.smelly?
            result << summarize_single_examiner(examiner)
          end
        end
      end
    end
  end
end
