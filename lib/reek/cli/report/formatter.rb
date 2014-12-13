module Reek
  module Cli
    module Report
      module Formatter
        def self.format_list(warnings, formatter = SimpleWarningFormatter)
          warnings.map do |warning|
            "  #{formatter.format warning}"
          end.join("\n")
        end

        def self.header(examiner)
          count = examiner.smells_count
          result = Rainbow("#{examiner.description} -- ").cyan +
                   Rainbow("#{count} warning").yellow
          result += Rainbow('s').yellow unless count == 1
          result
        end
      end

      module UltraVerboseWarningFormattter
        BASE_URL_FOR_HELP_LINK = 'https://github.com/troessner/reek/wiki/'

        module_function

        def format(warning)
          "#{WarningFormatterWithLineNumbers.format(warning)} " \
          "[#{explanatory_link(warning)}]"
        end

        def explanatory_link(warning)
          "#{BASE_URL_FOR_HELP_LINK}#{class_name_to_param(warning.smell_type)}"
        end

        def class_name_to_param(name)
          name.split(/(?=[A-Z])/).join('-')
        end
      end

      module SimpleWarningFormatter
        def self.format(warning)
          "#{warning.context} #{warning.message} (#{warning.smell_type})"
        end
      end

      module WarningFormatterWithLineNumbers
        def self.format(warning)
          "#{warning.lines.inspect}:#{SimpleWarningFormatter.format(warning)}"
        end
      end

      module SingleLineWarningFormatter
        def self.format(warning)
          "#{warning.source}:#{warning.lines.first}: " \
          "#{SimpleWarningFormatter.format(warning)}"
        end
      end
    end
  end
end
