require 'codeclimate_engine'
require 'private_attr'

module Reek
  module Report
    # Generates a hash in the structure specified by the Code Climate engine spec
    class CodeClimateFormatter
      private_attr_reader :warning

      def initialize(warning)
        @warning = warning
      end

      def to_hash
        CCEngine::Issue.new(check_name: check_name,
                            description: description,
                            categories: categories,
                            location: location
                           ).to_hash
      end

      private

      def description
        [warning.context, warning.message].join(' ')
      end

      def check_name
        [warning.smell_category, warning.smell_type].join('/')
      end

      def categories
        # TODO: provide mappings for Reek's smell categories
        ['Complexity']
      end

      def location
        warning_lines = warning.lines
        CCEngine::Location::LineRange.new(
          path: warning.source,
          line_range: warning_lines.first..warning_lines.last
        )
      end
    end
  end
end
