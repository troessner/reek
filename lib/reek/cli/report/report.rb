require 'rainbow'

module Reek
  module Cli
    module Report
      #
      # A report that contains the smells and smell counts following source code analysis.
      #
      class Base
        DefaultFormat = :text
        NoWarningsColor = :green
        WarningsColor = :red

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

        def has_smells?
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
          if has_smells?
            sort_examiners
          end
          display_summary
          display_total_smell_count
        end

        private

        def display_summary
          print smells.reject(&:empty?).join("\n")
        end

        def display_total_smell_count
          if @examiners.size > 1
            print "\n"
            print total_smell_count_message
          end
        end

        def sort_examiners
          @examiners.sort! {|first, second| second.smells_count <=> first.smells_count } if @sort_by_issue_count
        end

        def total_smell_count_message
          colour = has_smells? ? WarningsColor : NoWarningsColor
          Rainbow("#{@total_smell_count} total warning#{'s' unless @total_smell_count == 1 }\n").color(colour)
        end
      end

      #
      # Displays a list of smells in YAML format
      # YAML with empty array for 0 smells
      class YamlReport < Base
        def initialize(options ={})
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
        def initialize(options ={})
          @options = options
          super @options.merge!(strategy: Strategy::Normal)
        end

        require 'erb'

        TEMPLATE = File.read(File.expand_path('../../../../../assets/html_output.html.erb', __FILE__))

        def show
          File.open('reek.html', 'w+') do |file|
            file.puts ERB.new(TEMPLATE).result(binding)
          end
          print("Html file saved\n")
        end
      end
    end
  end
end
