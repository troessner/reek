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

  context 'with one visible item' do
    before :each do
      @item = "hello"
      @collection.found_smell(@item)
    end
    it_should_behave_like 'one visible item'
  end

  context 'with one visible item added twice' do
    before :each do
      @item = "hello"
      @collection.found_smell(@item)
      @collection.found_smell(@item)
    end
    it_should_behave_like 'one visible item'
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
end
