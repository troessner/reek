# frozen_string_literal: true

require_relative '../report/base_report'
require_relative 'code_climate_formatter'

module Reek
  module CodeClimate
    #
    # Displays a list of smells in Code Climate engine format
    # (https://github.com/codeclimate/spec/blob/master/SPEC.md)
    # JSON with empty array for 0 smells
    #
    class CodeClimateReport < Report::BaseReport
      def show(out = $stdout)
        smells.map do |smell|
          out.print CodeClimateFormatter.new(smell).render
        end
      end
    end
  end
end
