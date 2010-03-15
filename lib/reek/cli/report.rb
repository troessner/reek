module Reek
  module Cli

    module ReportFormatter
      def header(desc, count)
        result = "#{desc} -- #{count} warning"
        result += 's' unless count == 1
        result
      end

      def format_list(warnings)
        warnings.map do |warning|
          "  #{warning.context} #{warning.message} (#{warning.smell_class})"
        end.join("\n")
      end

      module_function :format_list
    end

    #
    # A report that lists every source, including those that have no smells.
    #
    class VerboseReport

      include ReportFormatter

      def initialize(examiner)
        @examiner = examiner
      end

      def report
        warnings = @examiner.smells
        warning_count = warnings.length
        result = header(@examiner.description, warning_count)
        result += ":\n#{format_list(warnings)}" if warning_count > 0
        result + "\n"
      end
    end

    #
    # A report that lists a section for each source that has smells.
    #
    class QuietReport

      include ReportFormatter

      def initialize(examiner)
        @warnings = examiner.smells
        @smell_count = @warnings.length
        @desc = examiner.description
      end

      def report
        @smell_count > 0 ? "#{header(@desc, @smell_count)}:\n#{format_list(@warnings)}\n" : ''
      end
    end
  end
end
