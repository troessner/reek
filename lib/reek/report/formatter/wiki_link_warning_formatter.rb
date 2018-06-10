# frozen_string_literal: true

require_relative 'simple_warning_formatter'

module Reek
  module Report
    module Formatter
      #
      # Formatter that adds a link to the wiki to the basic message from
      # SimpleWarningFormatter.
      #
      class WikiLinkWarningFormatter < SimpleWarningFormatter
        def format(warning)
          "#{super} [#{warning.explanatory_link}]"
        end

        def format_hash(warning)
          super.merge('wiki_link' => warning.explanatory_link)
        end
      end
    end
  end
end
