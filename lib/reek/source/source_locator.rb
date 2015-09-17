require 'descendants_tracker'

module Reek
  module Source
    #
    # Finds Ruby sources
    #
    class SourceLocator
      extend DescendantsTracker

      private_attr_reader :source

      def self.build(source)
        klass = descendants.find { |locator| locator.handle?(source) } || self
        klass.new(source)
      end

      def initialize(source)
        @source = source
      end

      def locate
        []
      end
    end
  end
end
