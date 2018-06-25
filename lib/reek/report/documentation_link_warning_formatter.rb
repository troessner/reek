# frozen_string_literal: true

require_relative 'simple_warning_formatter'

module Reek
  module Report
    #
    # Formatter that adds a link to the docs to the basic message from
    # SimpleWarningFormatter.
    #
    class DocumentationLinkWarningFormatter < SimpleWarningFormatter
      def format(warning)
        "#{super} [#{warning.explanatory_link}]"
      end
    end
  end
end
