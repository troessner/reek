# frozen_string_literal: true

module Reek
  # Generate versioned links to our documentation
  module DocumentationLink
    HELP_LINK_TEMPLATE = 'https://github.com/troessner/reek/blob/v%<version>s/docs/%<item>s.md'

    module_function

    # Build link to the documentation about the given subject for the current
    # version of Reek. The subject can be either a smell type like
    # 'FeatureEnvy' or a general subject like 'Rake Task'.
    #
    # @param subject [String]
    # @return [String] the full URL for the relevant documentation
    def build(subject)
      Kernel.format(HELP_LINK_TEMPLATE, version: Version::STRING, item: name_to_param(subject))
    end

    # Convert the given subject name to a form that is acceptable in a URL, by
    # dasherizeing it at the start of capitalized words. Spaces are discared.
    def name_to_param(name)
      name.split(/([A-Z][a-z][a-z]*)/).map(&:strip).reject(&:empty?).join('-')
    end
  end
end
