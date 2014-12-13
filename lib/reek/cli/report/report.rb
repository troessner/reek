require 'rainbow'

module Reek
  module Cli
    module Report
      #
      # A report that contains the smells and smell counts following source code analysis.
      #
      class Base
        DEFAULT_FORMAT = :text
        NO_WARNINGS_COLOR = :green
        WARNINGS_COLOR = :red

        def initialize(options = {})
          @warning_formatter   = options.fetch :warning_formatter, SimpleWarningFormatter
          @report_formatter    = options.fetch :report_formatter, Formatter
          @examiners           = []
          @total_smell_count   = 0
          @sort_by_issue_count = options.fetch :sort_by_issue_count, false
          @strategy = options.fetch(:strategy, Strategy::Quiet)
        end

        def add_examiner(examiner)
          @total_smell_count += examiner.smells_count
          @examiners << examiner
          self
        end

        def smells?
          @total_smell_count > 0
        end

        def smells
          @strategy.new(@report_formatter, @warning_formatter, @examiners).gather_results
        end
      end

      #
      # Generates a sorted, text summary of smells in examiners
      #
      class TextReport < Base
        def show
          sort_examiners if smells?
          display_summary
          display_total_smell_count
        end

        private

        def display_summary
          print smells.reject(&:empty?).join("\n")
        end

        def display_total_smell_count
          return unless @examiners.size > 1
          print "\n"
          print total_smell_count_message
        end

        def sort_examiners
          @examiners.sort_by!(&:smells_count).reverse! if @sort_by_issue_count
        end

        def total_smell_count_message
          colour = smells? ? WARNINGS_COLOR : NO_WARNINGS_COLOR
          s = @total_smell_count == 1 ? '' : 's'
          Rainbow("#{@total_smell_count} total warning#{s}\n").color(colour)
        end
      end

      #
      # Displays a list of smells in YAML format
      # YAML with empty array for 0 smells
      class YamlReport < Base
        def initialize(options = {})
          @options = options
          super options.merge!(strategy: Strategy::Normal)
        end

        def show
          print(smells.to_yaml)
        end
      end

      #
      # Saves the report as a HTML file
      #
      class HtmlReport < Base
        def initialize(options = {})
          @options = options
          super @options.merge!(strategy: Strategy::Normal)
        end

        require 'erb'

        def show
          path = File.expand_path('../../../../../assets/html_output.html.erb',
                                  __FILE__)
          File.open('reek.html', 'w+') do |file|
            file.puts ERB.new(File.read(path)).result(binding)
          end
          print("Html file saved\n")
        end
      end
    end
  end
end
