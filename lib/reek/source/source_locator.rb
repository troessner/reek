require 'pathname'
require 'forwardable'

module Reek
  module Source
    #
    # Finds Ruby source files in a filesystem.
    #
    class SourceLocator
      private_attr_reader :source

      def initialize(source)
        @source = source
      end

      def call
        locator.new(source).locate
      end

      def locate
        []
      end

      private

      def locator
        locators.find { |locator| locator.handle?(source) } || self
      end

      def locators
        [Stdin, Collection, Path]
      end

      # Finds sources in STDIN
      class Stdin < SourceLocator
        def self.handle?(source)
          source.is_a?(IO)
        end

        def locate
          [source]
        end
      end

      # Finds sources in collection
      class Collection < SourceLocator
        def self.handle?(source)
          source.is_a?(Enumerable)
        end

        def locate
          source.flat_map { |element| Source::SourceLocator.new(element).call }
        end
      end

      # Finds sources in Path
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
