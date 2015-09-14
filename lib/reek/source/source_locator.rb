require 'pathname'

module Reek
  module Source
    #
    # Finds Ruby source files in a filesystem.
    #
    class SourceLocator
      private_attr_reader :source

      def self.build(source)
        klass = [Stdin, Collection, Path].find { |locator| locator.handle?(source) } || self
        klass.new(source)
      end

      def initialize(source)
        @source = source
      end

      def locate
        []
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
          source.flat_map { |element| Source::SourceLocator.build(element).locate }
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
