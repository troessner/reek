require 'pathname'
require_relative '../source_locator'

module Reek
  module Source
    module Locators
      #
      # Finds Ruby sources in path
      #
      class Path < SourceLocator
        def self.handle?(source)
          source.is_a?(String)
        end

        def locate
          Source::SourcePath.new(Pathname.new(source)).sources
        end
      end
    end
  end
end
