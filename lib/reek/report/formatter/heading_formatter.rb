# frozen_string_literal: true

module Reek
  module Report
    module Formatter
      #
      # Base class for heading formatters.
      # Is responsible for formatting the heading emitted for each examiner
      #
      # @abstract Override {#show_header?} to implement a heading formatter.
      class HeadingFormatterBase
        attr_reader :report_formatter

        def initialize(report_formatter)
          @report_formatter = report_formatter
        end

        # :reek:UtilityFunction
        def show_header?(_examiner)
          raise NotImplementedError
        end

        def header(examiner)
          if show_header?(examiner)
            report_formatter.header examiner
          else
            ''
          end
        end
      end

      #
      # Lists out each examiner, even if it has no smell
      #
      class VerboseHeadingFormatter < HeadingFormatterBase
        def show_header?(_examiner)
          true
        end
      end

      #
      # Lists only smelly examiners
      #
      class QuietHeadingFormatter < HeadingFormatterBase
        # :reek:UtilityFunction
        def show_header?(examiner)
          examiner.smelly?
        end
      end
    end
  end
end
