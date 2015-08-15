require 'json'
require 'pathname'
require 'rainbow'
require_relative 'formatter'
require_relative 'heading_formatter'

module Reek
  module Report
    #
    # A report that contains the smells and smell counts following source code analysis.
    #
    # @abstract Subclass and override {#show} to create a concrete report class.
    class Base
      # @api private
      NO_WARNINGS_COLOR = :green
      # @api private
      WARNINGS_COLOR = :red

      def initialize(options = {})
        @examiners           = []
        @total_smell_count   = 0
        @options             = options
        @warning_formatter   = options.fetch :warning_formatter, SimpleWarningFormatter.new
        @report_formatter    = options.fetch :report_formatter, Formatter
        @sort_by_issue_count = options.fetch :sort_by_issue_count, false
      end

      # Add Examiner to report on. The report will output results for all
      # added examiners.
      #
      # @param [Reek::Examiner] examiner object to report on
      def add_examiner(examiner)
        self.total_smell_count += examiner.smells_count
        examiners << examiner
        self
      end

      # Render the report results on STDOUT
      def show
        raise NotImplementedError
      end

      # @api private
      def smells?
        total_smell_count > 0
      end

      # @api private
      def smells
        examiners.map(&:smells).flatten
      end

      protected

      attr_accessor :total_smell_count

      private

      private_attr_reader :examiners, :options, :report_formatter,
                          :sort_by_issue_count, :warning_formatter
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
                                                        warning_formatter)
          result += ":\n#{formatted_list}"
        end
        result
      end

      def sort_examiners
        examiners.sort_by!(&:smells_count).reverse! if sort_by_issue_count
      end

      def total_smell_count_message
        colour = smells? ? WARNINGS_COLOR : NO_WARNINGS_COLOR
        s = total_smell_count == 1 ? '' : 's'
        Rainbow("#{total_smell_count} total warning#{s}\n").color(colour)
      end

      def heading_formatter
        @heading_formatter ||=
          options.fetch(:heading_formatter, HeadingFormatter::Quiet).new(report_formatter)
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
            smell.yaml_hash(warning_formatter)
          end
        )
      end
    end

    #
    # Saves the report as a HTML file
    #
    class HTMLReport < Base
      require 'erb'

      def show(target_path = Pathname.new('reek.html'))
        template_path = Pathname.new("#{__dir__}/html_report.html.erb")
        File.write target_path, ERB.new(template_path.read).result(binding)
        puts 'HTML file saved'
      end
    end

    #
    # Generates a list of smells in XML format
    #
    class XMLReport < Base
      require 'rexml/document'

      def show
        document.write output: $stdout, indent: 2
        $stdout.puts
      end

      private

      def document
        REXML::Document.new.tap do |document|
          document << REXML::XMLDecl.new << checkstyle
        end
      end

      def checkstyle
        REXML::Element.new('checkstyle').tap do |checkstyle|
          smells.group_by(&:source).each do |source, source_smells|
            checkstyle << file(source, source_smells)
          end
        end
      end

      def file(name, smells)
        REXML::Element.new('file').tap do |file|
          file.add_attribute 'name', File.realpath(name)
          smells.each do |smell|
            smell.lines.each do |line|
              file << error(smell, line)
            end
          end
        end
      end

      def error(smell, line)
        REXML::Element.new('error').tap do |error|
          error.add_attributes 'column'   => 0,
                               'line'     => line,
                               'message'  => smell.message,
                               'severity' => 'warning',
                               'source'   => smell.smell_type
        end
      end
    end
  end
end
