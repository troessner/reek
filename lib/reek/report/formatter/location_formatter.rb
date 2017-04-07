# frozen_string_literal: true

module Reek
  module Report
    module Formatter
      #
      # Formats the location of a warning as an empty string.
      #
      module BlankLocationFormatter
        module_function

        def format(_warning)
          ''
        end
      end

      #
      # Formats the location of a warning as an array of line numbers.
      #
      module DefaultLocationFormatter
        module_function

        def format(warning)
          "#{warning.lines.sort.inspect}:"
        end
      end

      #
      # Formats the location of a warning as a combination of source file name
      # and line number. In this format, it is not possible to show more than
      # one line number, so the first number is displayed.
      #
      module SingleLineLocationFormatter
        module_function

        def format(warning)
          "#{warning.source}:#{warning.lines.sort.first}: "
        end
      end
    end
  end
end
