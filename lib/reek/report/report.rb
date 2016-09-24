# frozen_string_literal: true
require 'json'
require 'pathname'
require 'rainbow'
require_relative 'formatter'
require_relative 'heading_formatter'
require_relative 'progress_formatter'

module Reek
  # @public
  module Report
    #
    # A report that contains the smells and smell counts following source code analysis.
    #
    # @abstract Subclass and override {#show} to create a concrete report class.
    #
    # @public
    #
    # :reek:TooManyInstanceVariables: { max_instance_variables: 7 }
    class Base
      NO_WARNINGS_COLOR = :green
      WARNINGS_COLOR = :red

      # @public
      #
      # :reek:BooleanParameter
      def initialize(heading_formatter: HeadingFormatter::Quiet,
                     report_formatter: Formatter, sort_by_issue_count: false,
                     warning_formatter: SimpleWarningFormatter.new,
                     progress_formatter: ProgressFormatter::Quiet.new(0))
        @examiners           = []
        @heading_formatter   = heading_formatter.new(report_formatter)
        @report_formatter    = report_formatter
        @progress_formatter  = progress_formatter
        @sort_by_issue_count = sort_by_issue_count
        @total_smell_count   = 0
        @warning_formatter   = warning_formatter

        # TODO: Only used in TextReport and YAMLReport
      end

      # Add Examiner to report on. The report will output results for all
      # added examiners.
      #
      # @param [Reek::Examiner] examiner object to report on
      #
      # @public
      def add_examiner(examiner)
        self.total_smell_count += examiner.smells_count
        examiners << examiner
        self
      end

      # Render the report results on STDOUT
      #
      # @public
      def show
        raise NotImplementedError
      end

      def smells?
        total_smell_count > 0
      end

      def smells
        examiners.map(&:smells).flatten
      end

      protected

      attr_accessor :total_smell_count

      private

      attr_reader :examiners, :heading_formatter, :report_formatter,
                  :sort_by_issue_count, :warning_formatter, :progress_formatter
    end

    #
    # Generates a sorted, text summary of smells in examiners
    #
    # @public
    class TextReport < Base
      # @public
      def initialize(*args)
        super(*args)

        progress_formatter.header
      end

      # @public
      def add_examiner(examiner)
        progress_formatter.progress examiner
        super(examiner)
      end

      # @public
      def show
        sort_examiners if smells?
        progress_formatter.footer
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

    #
    # Displays a list of smells in YAML format
    # YAML with empty array for 0 smells
    #
    # @public
    class YAMLReport < Base
      # @public
      def show(out = $stdout)
        out.print smells.map { |smell| warning_formatter.format_hash(smell) }.to_yaml
      end
    end

    #
    # Displays a list of smells in JSON format
    # JSON with empty array for 0 smells
    #
    # @public
    class JSONReport < Base
      # @public
      def show(out = $stdout)
        out.print ::JSON.generate smells.map { |smell| warning_formatter.format_hash(smell) }
      end
    end

    #
    # Displays a list of smells in Code Climate engine format
    # (https://github.com/codeclimate/spec/blob/master/SPEC.md)
    # JSON with empty array for 0 smells
    #
    class CodeClimateReport < Base
      # @public
      def show(out = $stdout)
        smells.map do |smell|
          out.print warning_formatter.format_code_climate_hash(smell)
        end
      end
    end

    #
    # Saves the report as a HTML file
    #
    # @public
    class HTMLReport < Base
      require 'erb'

      # @public
      def show
        template_path = Pathname.new("#{__dir__}/html_report.html.erb")
        puts ERB.new(template_path.read).result(binding)
      end
    end

    #
    # Generates a list of smells in XML format
    #
    # @public
    class XMLReport < Base
      require 'rexml/document'

      # @public
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

      # :reek:FeatureEnvy
      # :reek:NestedIterators: { max_allowed_nesting: 2 }
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

      # :reek:UtilityFunction
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
