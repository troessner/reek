module Reek
  module Cli

    module ReportFormatter
      def header(desc, count)
        result = "#{desc} -- #{count} warning"
        result += 's' unless count == 1
        result
      end

      def format(warning)
        masked = warning.is_active ? '' : '(masked) '
#        "#{warning.smell_class}#{subclass}#{masked}: #{warning.context} #{warning.message} (#{warning.lines.join(',')})"
        "#{masked}#{warning.context} #{warning.message} (#{warning.smell_class})"
      end

      def smell_list(warnings)
        warnings.map {|warning| "  #{format(warning)}"}.join("\n")
      end
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
        smells = @examiner.smells
        smell_count = smells.length
        result = header(@examiner.description, smell_count)
        result += ":\n#{smell_list(smells)}" if smell_count > 0
        result + "\n"
      end
    end

    #
    # A report that lists a section for each source that has smells.
    #
    class QuietReport

      include ReportFormatter

      def initialize(examiner)
        @smells = examiner.smells
        @smell_count = @smells.length
        @desc = examiner.description
      end

      def report
        @smell_count > 0 ? "#{header(@desc, @smell_count)}:\n#{smell_list(@smells)}\n" : ''
      end
    end
  end
end
