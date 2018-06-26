# frozen_string_literal: true

module Reek
  module Report
    #
    # Base class for heading formatters.
    # Is responsible for formatting the heading emitted for each examiner
    #
    # @abstract Override {#show_header?} to implement a heading formatter.
    class HeadingFormatterBase
      # @quality :reek:UtilityFunction
      def show_header?(_examiner)
        raise NotImplementedError
      end

      def header(examiner)
        if show_header?(examiner)
          formatted_header examiner
        else
          ''
        end
      end

      private

      def formatted_header(examiner)
        count = examiner.smells_count
        result = Rainbow("#{examiner.origin} -- ").cyan +
          Rainbow("#{count} warning").yellow
        result += Rainbow('s').yellow unless count == 1
        result
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
      # @quality :reek:UtilityFunction
      def show_header?(examiner)
        examiner.smelly?
      end
    end
  end
end
