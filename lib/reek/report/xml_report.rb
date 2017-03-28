# frozen_string_literal: true

require_relative 'base_report'

module Reek
  module Report
    #
    # Generates a list of smells in XML format
    #
    # @public
    #
    class XMLReport < BaseReport
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
          error.add_attributes 'column' => 0,
                               'line' => line,
                               'message' => smell.message,
                               'severity' => 'warning',
                               'source' => smell.smell_type
        end
      end
    end
  end
end
