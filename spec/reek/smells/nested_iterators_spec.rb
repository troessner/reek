require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/nested_iterators'

include Reek::Smells

describe NestedIterators do

  it 'should report nested iterators in a method' do
    'def bad(fred) @fred.each {|item| item.each {|ting| ting.ting} } end'.should reek_only_of(:NestedIterators)
  end

  it 'should not report method with successive iterators' do
    'def bad(fred)
      @fred.each {|item| item.each }
      @jim.each {|ting| ting.each }
    end'.should_not reek
  end

  it 'should not report method with chained iterators' do
    'def chained
      @sig.keys.sort_by { |xray| xray.to_s }.each { |min| md5 << min.to_s }
    end'.should_not reek
  end

  it 'should report nested iterators only once per method' do
    'def bad(fred)
      @fred.each {|item| item.each {|part| @joe.send} }
      @jim.each {|ting| ting.each {|piece| @hal.send} }
    end'.should reek_only_of(:NestedIterators)
  end
end

