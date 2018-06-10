# frozen_string_literal: true

module Reek
  # Generate versioned links to our documentation
  module DocumentationLink
    HELP_LINK_TEMPLATE = 'https://github.com/troessner/reek/blob/v%<version>s/docs/%<item>s.md'.freeze

    module_function

    def build(item)
      Kernel.format(HELP_LINK_TEMPLATE, version: Version::STRING, item: item_name_to_param(item))
    end

    def item_name_to_param(name)
      name.split(/ *(?=[A-Z])/).join('-')
    end
  end
end
