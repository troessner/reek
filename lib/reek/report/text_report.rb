# frozen_string_literal: true

require_relative 'base_report'

module Reek
  module Report
    #
    # Generates a sorted, text summary of smells in examiners
    #
    # @public
    #
    class TextReport < BaseReport
      # @public
      def initialize(*args)
        super(*args)

        print progress_formatter.header
      end

      # @public
      def add_examiner(examiner)
        print progress_formatter.progress examiner
        super(examiner)
      end

      # @public
      def show
        sort_examiners if smells?
        print progress_formatter.footer
        display_summary
        display_total_smell_count
      end

      private

      def smell_summaries
        examiners.map { |ex| summarize_single_examiner(ex) }.reject(&:empty?)
      end

      def display_summary
        smell_summaries.each { |smell| puts smell }
      end

      def display_total_smell_count
        return unless examiners.size > 1
        print total_smell_count_message
      end

      def summarize_single_examiner(examiner)
        result = heading_formatter.header(examiner)
        if examiner.smelly?
          formatted_list = report_formatter.format_list(examiner.smells,
                                                        formatter: warning_formatter)
          result += ":\n#{formatted_list}"
        end
        result
      end

      def sort_examiners
        examiners.sort_by!(&:smells_count).reverse! if sort_by_issue_count
      end

      def total_smell_count_message
        colour = smells? ? WARNINGS_COLOR : NO_WARNINGS_COLOR
        Rainbow("#{total_smell_count} total warning#{total_smell_count == 1 ? '' : 's'}\n").color(colour)
      end
    end
  end
end
