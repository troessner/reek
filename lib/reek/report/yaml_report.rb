# frozen_string_literal: true

require_relative 'base_report'

module Reek
  module Report
    #
    # Displays a list of smells in YAML format
    # YAML with empty array for 0 smells
    #
    # @public
    #
    class YAMLReport < BaseReport
      def show(out = $stdout)
        out.print smells.map { |smell| warning_formatter.format_hash(smell) }.to_yaml
      end
    end
  end
end
