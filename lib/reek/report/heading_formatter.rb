module Reek
  module Report
    module HeadingFormatter
      #
      # Base class for heading formatters.
      # Is responsible for formatting the heading emitted for each examiner
      #
      # @abstract Override {#show_header?} to implement a heading formatter.
      class Base
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
      class Verbose < Base
        def show_header?(_examiner)
          true
        end
      end

      #
      # Lists only smelly examiners
      #
      class Quiet < Base
        # :reek:UtilityFunction
        def show_header?(examiner)
          examiner.smelly?
        end
      end
    end
  end
end
