require 'set'

module Reek
  module Core

    #
    # A set of items that can be "masked" or "visible". If an item is added
    # more than once, only the "visible" copy is retained.
    #
    class MaskingCollection
      def initialize
        @visible_items = SortedSet.new
      end

      def collect_from(sources, config)
        sources.each { |src| Core::Sniffer.new(src, config).report_on(self) }
        self
      end

      def all_items
        all = SortedSet.new(@visible_items)
        all.to_a
      end
      def all_active_items
        @visible_items
      end
      def found_smell(item)
        @visible_items.add(item)
      end
      def num_visible_items
        @visible_items.length
      end
      def each_item(&blk)
        all = SortedSet.new(@visible_items)
        all.each(&blk)
      end
      def each_visible_item(&blk)
        @visible_items.each(&blk)
      end
    end
  end
end
