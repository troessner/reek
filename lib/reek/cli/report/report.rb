require 'rainbow'
require 'json'

module Reek
  module CLI
    module Report
      #
      # A report that contains the smells and smell counts following source code analysis.
      #
      class Base
        DEFAULT_FORMAT = :text
        NO_WARNINGS_COLOR = :green
        WARNINGS_COLOR = :red

        def initialize(options = {})
          @examiners           = []
          @total_smell_count   = 0
          @options             = options
          @warning_formatter   = options.fetch :warning_formatter, SimpleWarningFormatter.new
          @report_formatter    = options.fetch :report_formatter, Formatter
          @sort_by_issue_count = options.fetch :sort_by_issue_count, false
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
          @examiners.map(&:smells).flatten
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

        def smells
          @examiners.each_with_object([]) do |examiner, result|
            result << summarize_single_examiner(examiner)
          end
        end

        private

        def display_summary
          smells.reject(&:empty?).each { |smell| puts smell }
        end

        def display_total_smell_count
          return unless @examiners.size > 1
          print total_smell_count_message
        end

        def summarize_single_examiner(examiner)
          result = heading_formatter.header(examiner)
          if examiner.smelly?
            formatted_list = @report_formatter.format_list(examiner.smells,
                                                           @warning_formatter)
            result += ":\n#{formatted_list}"
          end
          result
        end

        def sort_examiners
          @examiners.sort_by!(&:smells_count).reverse! if @sort_by_issue_count
        end

        def total_smell_count_message
          colour = smells? ? WARNINGS_COLOR : NO_WARNINGS_COLOR
          s = @total_smell_count == 1 ? '' : 's'
          Rainbow("#{@total_smell_count} total warning#{s}\n").color(colour)
        end

        def heading_formatter
          @heading_formatter ||=
            @options.fetch(:heading_formatter, HeadingFormatter::Quiet).new(@report_formatter)
        end
      end

      #
      # Displays a list of smells in YAML format
      # YAML with empty array for 0 smells
      class YAMLReport < Base
        def show
          print smells.map(&:yaml_hash).to_yaml
        end
      end

      #
      # Displays a list of smells in JSON format
      # JSON with empty array for 0 smells
      class JSONReport < Base
        def show
          print ::JSON.generate(
            smells.map do |smell|
              smell.yaml_hash(@warning_formatter)
            end
          )
        end
      end

      #
      # Saves the report as a HTML file
      #
      class HTMLReport < Base
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

      #
      # Generates a list of smells in XML format
      #
      class XMLReport < Base
        require 'rexml/document'

        def initialize(options = {})
          super options
        end

        def show
          checkstyle = REXML::Element.new('checkstyle', document)

          smells.group_by(&:source).each do |file, file_smells|
            file_to_xml(file, file_smells, checkstyle)
          end

          print_xml(checkstyle.parent)
        end

        private

        def document
          REXML::Document.new.tap do |doc|
            doc << REXML::XMLDecl.new
          end
        end

        def file_to_xml(file, file_smells, parent)
          REXML::Element.new('file', parent).tap do |element|
            element.attributes['name'] = File.realpath(file)
            smells_to_xml(file_smells, element)
          end
        end

        def smells_to_xml(smells, parent)
          smells.each do |smell|
            smell_to_xml(smell, parent)
          end
        end

        def smell_to_xml(smell, parent)
          REXML::Element.new('error', parent).tap do |element|
            attributes = [
              ['line', smell.lines.first],
              ['column', 0],
              ['severity', 'warning'],
              ['message', smell.message],
              ['source', smell.smell_type]
            ]
            element.add_attributes(attributes)
          end
        end

        def print_xml(document)
          formatter = REXML::Formatters::Default.new
          puts formatter.write(document, '')
        end
      end
    end
  end
end
