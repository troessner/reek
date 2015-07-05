module Reek
  module Report
    #
    # Formats the location of a warning as an empty string.
    #
    # @api private
    module BlankLocationFormatter
      def self.format(_warning)
        ''
      end
    end

    #
    # Formats the location of a warning as an array of line numbers.
    #
    # @api private
    module DefaultLocationFormatter
      def self.format(warning)
        "#{warning.lines.inspect}:"
      end
    end

    #
    # Formats the location of a warning as a combination of source file name
    # and line number. In this format, it is not possible to show more than
    # one line number, so the first number is displayed.
    #
    # @api private
    module SingleLineLocationFormatter
      def self.format(warning)
        "#{warning.source}:#{warning.lines.first}: "
      end
    end
  end
end
