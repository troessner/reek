require 'rainbow'

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
        result = Rainbow("#{examiner.description} -- ").cyan + Rainbow("#{count} warning").yellow
        result += Rainbow('s').yellow unless count == 1
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

    class UnsupportedReportFormatError < StandardError; end

    #
    # A report that contains the smells and smell counts following source code analysis.
    #
    class Report
      DefaultFormat = :text
      NoWarningsColor = :green
      WarningsColor = :red

      FORMAT_WHITELIST = [:text, :html, :yaml]

      def initialize(options = {})
        @warning_formatter   = options.fetch :warning_formatter, SimpleWarningFormatter
        @report_formatter    = options.fetch :report_formatter, ReportFormatter
        @examiners           = []
        @total_smell_count   = 0
        @sort_by_issue_count = options.fetch :sort_by_issue_count, false
        @format = options[:format] ? validate_format(options[:format]) : DefaultFormat
      end

      def add_examiner(examiner)
        @total_smell_count += examiner.smells_count
        @examiners << examiner
        self
      end

      def show
          send("as_#{@format}")
      end

      def has_smells?
        @total_smell_count > 0
      end

      private

      def validate_format(format)
        unless FORMAT_WHITELIST.include? format
          raise UnsupportedReportFormatError
        end
        format
      end

      def as_html
        HtmlReport.new(all_smells).output
        print("Html file saved\n")
      end

      def as_text
        if has_smells?
          sort_examiners
        end
        display_summary
        display_total_smell_count
      end

      def as_yaml
        print(all_smells.to_yaml)
      end

      def all_smells
        @all_smells ||= @examiners.each_with_object([]) { |examiner, smells| smells << examiner.smells }
                                                      .flatten
      end

      def sort_examiners
        @examiners.sort! {|first, second| second.smells_count <=> first.smells_count } if @sort_by_issue_count
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
        colour = has_smells? ? WarningsColor : NoWarningsColor
        Rainbow("#{@total_smell_count} total warning#{'s' unless @total_smell_count == 1 }\n").color(colour)
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

    #
    # A report that lists smell-free source files.
    #
    class VerboseReport < Report
      def gather_results
        @examiners.each_with_object([]) do |examiner, result|
          result << summarize_single_examiner(examiner)
        end
      end
    end

    #
    # A report that does not list smell-free source files.
    #
    class QuietReport < Report
      def gather_results
        @examiners.each_with_object([]) do |examiner, result|
          if examiner.smelly?
            result << summarize_single_examiner(examiner)
          end
        end
      end
    end

    #
    # Saves the report as a HTML file
    #
    class HtmlReport < Report
      require 'erb'

      TEMPLATE = File.read(File.expand_path('../../../../assets/html_output.html.erb', __FILE__))

      attr_reader:smells

      def initialize(smells)
        @smells = smells
      end

      def output
        File.open('reek.html', 'w+') do |file|
          file.puts ERB.new(TEMPLATE).result(binding)
        end
      end
    end
  end
end
