require_relative '../source_locator'

module Reek
  module Source
    module Locators
      #
      # Finds Ruby sources in collection of sources
      #
      class Collection < SourceLocator
        def self.handle?(source)
          source.is_a?(Enumerable)
        end

        def locate
          source.flat_map { |element| Source::SourceLocator.build(element).locate }
        end
      end
    end
  end
end
