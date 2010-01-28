require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'masking_collection')

include Reek::Core

describe MaskingCollection do
  before(:each) do
    @collection = MaskingCollection.new
  end

  context 'when empty' do
    it 'has no visible items' do
      @collection.num_visible_items.should == 0
    end
    it 'has no masked items' do
      @collection.num_masked_items.should == 0
    end
    it 'yields no items' do
      count = 0
      @collection.each_item {|item| count+= 1}
      count.should == 0
    end
    it 'yields no visible items' do
      count = 0
      @collection.each_visible_item {|item| count+= 1}
      count.should == 0
    end
  end

  shared_examples_for 'one visible item' do
    it 'has one visible item' do
      @collection.num_visible_items.should == 1
    end
    it 'has no masked items' do
      @collection.num_masked_items.should == 0
    end
    it 'yields one item' do
      count = 0
      @collection.each_item do |item|
        item.should == @item
        count+= 1
      end
      count.should == 1
    end
    it 'yields one visible item' do
      count = 0
      @collection.each_visible_item do |item|
        item.should == @item
        count+= 1
      end
      count.should == 1
    end
  end

  shared_examples_for 'one masked item' do
    it 'has no visible items' do
      @collection.num_visible_items.should == 0
    end
    it 'has one masked item' do
      @collection.num_masked_items.should == 1
    end
    it 'yields one item' do
      count = 0
      @collection.each_item do |item|
        item.should == @item
        count+= 1
      end
      count.should == 1
    end
    it 'yields no visible items' do
      count = 0
      @collection.each_visible_item { |item| count+= 1 }
      count.should == 0
    end
  end

  context 'with one visible item' do
    before :each do
      @item = "hello"
      @collection.found_smell(@item)
    end
    it_should_behave_like 'one visible item'
  end

  context 'with one masked item' do
    before :each do
      @item = "hiding!"
      @collection.found_masked_smell(@item)
    end
    it_should_behave_like 'one masked item'
  end

  context 'with one masked and one visible' do
    before :each do
      @visible = "visible"
      @masked = "masked"
      @collection.found_masked_smell(@masked)
      @collection.found_smell(@visible)
    end
    it 'has one visible item' do
      @collection.num_visible_items.should == 1
    end
    it 'has one masked item' do
      @collection.num_masked_items.should == 1
    end
    it 'yields both items' do
      yielded_items = []
      @collection.each_item { |item| yielded_items << item }
      yielded_items.length.should == 2
      yielded_items.should include(@visible)
      yielded_items.should include(@masked)
    end
    it 'yields one visible item' do
      count = 0
      @collection.each_visible_item do |item|
        item.should == @visible
        count+= 1
      end
      count.should == 1
    end
    it 'yields the items in sort order' do
      yielded_items = []
      @collection.each_item { |item| yielded_items << item }
      yielded_items.length.should == 2
      yielded_items[0].should == @masked
      yielded_items[1].should == @visible
    end
  end

  context 'with one visible item added twice' do
    before :each do
      @item = "hello"
      @collection.found_smell(@item)
      @collection.found_smell(@item)
    end
    it_should_behave_like 'one visible item'
  end

  context 'with one masked item added twice' do
    before :each do
      @item = "hello"
      @collection.found_masked_smell(@item)
      @collection.found_masked_smell(@item)
    end
    it_should_behave_like 'one masked item'
  end

  context 'with two different visible items' do
    before :each do
      @first_item = "hello"
      @second_item = "goodbye"
      @collection.found_smell(@first_item)
      @collection.found_smell(@second_item)
    end
    it 'has 2 visible items' do
      @collection.num_visible_items.should == 2
    end
    it 'has no masked items' do
      @collection.num_masked_items.should == 0
    end
    it 'yields both items' do
      yielded_items = []
      @collection.each_item { |item| yielded_items << item }
      yielded_items.length.should == 2
      yielded_items.should include(@first_item)
      yielded_items.should include(@second_item)
    end
    it 'yields both visible items' do
      yielded_items = []
      @collection.each_visible_item { |item| yielded_items << item }
      yielded_items.length.should == 2
      yielded_items.should include(@first_item)
      yielded_items.should include(@second_item)
    end
    it 'yields the items in sort order' do
      yielded_items = []
      @collection.each_visible_item { |item| yielded_items << item }
      yielded_items.length.should == 2
      yielded_items[0].should == @second_item
      yielded_items[1].should == @first_item
    end
  end

  context 'with two different masked items' do
    before :each do
      @first_item = "hello"
      @second_item = "goodbye"
      @collection.found_masked_smell(@first_item)
      @collection.found_masked_smell(@second_item)
    end
    it 'has 0 visible items' do
      @collection.num_visible_items.should == 0
    end
    it 'has 2 masked items' do
      @collection.num_masked_items.should == 2
    end
    it 'yields both items' do
      yielded_items = []
      @collection.each_item { |item| yielded_items << item }
      yielded_items.length.should == 2
      yielded_items.should include(@first_item)
      yielded_items.should include(@second_item)
    end
    it 'yields no visible items' do
      count = 0
      @collection.each_visible_item { |item| count+= 1 }
      count.should == 0
    end
    it 'yields the items in sort order' do
      yielded_items = []
      @collection.each_item { |item| yielded_items << item }
      yielded_items.length.should == 2
      yielded_items[0].should == @second_item
      yielded_items[1].should == @first_item
    end
  end

  context 'with one masked item later made visible' do
    before :each do
      @item = "hello"
      @collection.found_masked_smell(@item)
      @collection.found_smell(@item)
    end
    it_should_behave_like 'one visible item'
  end

  context 'with one visible item later masked' do
    before :each do
      @item = "hello"
      @collection.found_smell(@item)
      @collection.found_masked_smell(@item)
    end
    it_should_behave_like 'one visible item'
  end
end
