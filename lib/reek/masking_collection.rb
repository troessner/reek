require 'set'

#
# A set of items that can be "masked" or "visible". If an item is added
# more than once, only the "visible" copy is retained.
#
class MaskingCollection
  def initialize
    @visible_items = SortedSet.new
    @masked_items = SortedSet.new
  end
  def all_items
    all = SortedSet.new(@visible_items)
    all.merge(@masked_items)
    all.to_a
  end
  def all_active_items
    @visible_items
  end
  def found_smell(item)
    @visible_items.add(item)
    @masked_items.delete(item) if @masked_items.include?(item)
  end
  def found_masked_smell(item)
    @masked_items.add(item) unless @visible_items.include?(item)
  end
  def num_visible_items
    @visible_items.length
  end
  def num_masked_items
    @masked_items.length
  end
  def each_item(&blk)
    all = SortedSet.new(@visible_items)
    all.merge(@masked_items)
    all.each(&blk)
  end
  def each_visible_item(&blk)
    @visible_items.each(&blk)
  end
end
