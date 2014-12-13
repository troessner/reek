module Reek
  module Cli
    module Report
      module Strategy
        #
        # Base class for report startegies.
        # Each gathers results according to strategy chosen
        #
        class Base
          attr_reader :report_formatter, :warning_formatter, :examiners

          def initialize(report_formatter, warning_formatter, examiners)
            @report_formatter = report_formatter
            @warning_formatter = warning_formatter
            @examiners = examiners
          end

          def summarize_single_examiner(examiner)
            result = report_formatter.header examiner
            if examiner.smelly?
              formatted_list = report_formatter.format_list(examiner.smells,
                                                            warning_formatter)
              result += ":\n#{formatted_list}"
            end
            result
          end
        end

        #
        # Lists out each examiner, even if it has no smell
        #
        class Verbose < Base
          def gather_results
            examiners.each_with_object([]) do |examiner, result|
              result << summarize_single_examiner(examiner)
            end
          end
        end

        #
        # Lists only smelly examiners
        #
        class Quiet < Base
          def gather_results
            examiners.each_with_object([]) do |examiner, result|
              result << summarize_single_examiner(examiner) if examiner.smelly?
            end
          end
        end

        #
        # Lists smells without summarization
        # Used for yaml and html reports
        #
        class Normal < Base
          def gather_results
            examiners.each_with_object([]) { |examiner, smells| smells << examiner.smells }.
              flatten
          end
        end
      end
    end
  end
end
