# frozen_string_literal: true

module Reek
  module Report
    module Formatter
      module ProgressFormatter
        #
        # Base class for progress formatters.
        # Is responsible for formatting the progress emitted for each examiner
        #
        # @abstract Override {#header, #progress, #footer} to implement a progress formatter.
        class Base
          attr_reader :sources_count

          def initialize(sources_count)
            @sources_count = sources_count
          end

          def header
            raise NotImplementedError
          end

          def progress(_examiner)
            raise NotImplementedError
          end

          def footer
            raise NotImplementedError
          end
        end

        #
        # Shows the status of each source as either a dot (.) or an S
        #
        class Dots < Base
          NO_WARNINGS_COLOR = :green
          WARNINGS_COLOR = :red

          def header
            "Inspecting #{sources_count} file(s):\n"
          end

          def progress(examiner)
            examiner.smelly? ? display_smelly : display_clean
          end

          def footer
            "\n\n"
          end

          private

          def display_clean
            Rainbow('.').color(NO_WARNINGS_COLOR)
          end

          def display_smelly
            Rainbow('S').color(WARNINGS_COLOR)
          end
        end

        #
        # Does not show progress
        #
        class Quiet < Base
          def header
            ''
          end

          def progress(_examiner)
            ''
          end

          def footer
            ''
          end
        end
      end
    end
  end
end
