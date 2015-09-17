require_relative '../source_locator'

module Reek
  module Source
    module Locators
      #
      # Finds Ruby sources in STDIN
      #
      class Stdin < SourceLocator
        def self.handle?(source)
          source.is_a?(IO)
        end

        def locate
          [source]
        end
      end
    end
  end
end
