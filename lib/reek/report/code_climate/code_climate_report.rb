# frozen_string_literal: true

require_relative '../base_report'

module Reek
  module Report
    #
    # Displays a list of smells in Code Climate engine format
    # (https://github.com/codeclimate/spec/blob/master/SPEC.md)
    # JSON with empty array for 0 smells
    #
    class CodeClimateReport < BaseReport
      def show(out = $stdout)
        smells.map do |smell|
          out.print warning_formatter.format_code_climate_hash(smell)
        end
      end
    end
  end
end
