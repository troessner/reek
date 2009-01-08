require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/smells'

include Reek

describe SmellWarning, ' in comparisons' do
  it 'should hash equal when the smell is the same' do
    SmellWarning.new('ha', self, self).hash.should == SmellWarning.new('ha', self, self).hash
  end

  it 'should compare equal when the smell is the same' do
    SmellWarning.new('ha', self, self).should == SmellWarning.new('ha', self, self)
  end

  it 'should compare equal when using <=>' do
    (SmellWarning.new('ha', self, self) <=> SmellWarning.new('ha', self, self)).should == 0
  end
end