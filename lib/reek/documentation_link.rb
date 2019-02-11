# frozen_string_literal: true

module Reek
  # Generate versioned links to our documentation
  module DocumentationLink
    HELP_LINK_TEMPLATE = 'https://github.com/troessner/reek/blob/v%<version>s/docs/%<item>s.md'
    RAW_HELP_LINK_TEMPLATE = 'https://raw.githubusercontent.com/troessner/reek/v%<version>s/docs/%<item>s.md'

    module_function

    # Build documentation links about the given subject for the current
    # version of Reek. The subject can be either a smell type like
    # 'FeatureEnvy' or a general subject like 'Rake Task'.
    #
    # @param subject [String]
    # @return [Hash{Symbol => String, Symbol => String}] with the full URL for the relevant documentation
    # and the full URL for markdown documentation
    def build(subject)
      item = name_to_param(subject)
      { html: Kernel.format(HELP_LINK_TEMPLATE, version: Version::STRING, item: item),
        markdown: Kernel.format(RAW_HELP_LINK_TEMPLATE, version: Version::STRING, item: item) }
    end

    # Convert the given subject name to a form that is acceptable in a URL.
    def name_to_param(name)
      # Splits the subject on the start of capitalized words, optionally
      # preceded by a space. The space is discarded, the start of the word is
      # not.
      name.split(/ *(?=[A-Z][a-z])/).join('-')
    end
  end
end
