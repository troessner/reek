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
        out.print smells.map(&:yaml_hash).to_yaml
      end
    end
  end
end
