require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'object_refs')

include Reek::Core

describe ObjectRefs, 'when empty' do
  before(:each) do
    @refs = ObjectRefs.new
  end

  it 'should report no refs to self' do
    @refs.refs_to_self.should == 0
  end
end

describe ObjectRefs, 'with no refs to self' do
  before(:each) do
    @refs = ObjectRefs.new
    @refs.record_ref('a')
    @refs.record_ref('b')
    @refs.record_ref('a')
  end

  it 'should report no refs to self' do
    @refs.refs_to_self.should == 0
  end

  it 'should report :a as the max' do
    @refs.max_keys.should == {'a' => 2}
  end

  it 'should not report self as the max' do
    @refs.self_is_max?.should == false
  end
end

describe ObjectRefs, 'with one ref to self' do
  before(:each) do
    @refs = ObjectRefs.new
    @refs.record_ref('a')
    @refs.record_ref('b')
    @refs.record_ref('a')
    @refs.record_reference_to_self
  end

  it 'should report 1 ref to self' do
    @refs.refs_to_self.should == 1
  end

  it 'should not report self among the max' do
    @refs.max_keys.should be_include('a')
    @refs.max_keys.should_not include(Sexp.from_array([:lit, :self]))
  end

  it 'should not report self as the max' do
    @refs.self_is_max?.should == false
  end
end

describe ObjectRefs, 'with many refs to self' do
  before(:each) do
    @refs = ObjectRefs.new
    @refs.record_reference_to_self
    @refs.record_reference_to_self
    @refs.record_ref('a')
    @refs.record_reference_to_self
    @refs.record_ref('b')
    @refs.record_ref('a')
    @refs.record_reference_to_self
  end

  it 'should report all refs to self' do
    @refs.refs_to_self.should == 4
  end

  it 'should report self among the max' do
    @refs.max_keys.should == {Sexp.from_array([:lit, :self]) => 4}
  end

  it 'should report self as the max' do
    @refs.self_is_max?.should == true
  end
end

describe ObjectRefs, 'when self is not the only max' do
  before(:each) do
    @refs = ObjectRefs.new
    @refs.record_ref('a')
    @refs.record_reference_to_self
    @refs.record_reference_to_self
    @refs.record_ref('b')
    @refs.record_ref('a')
  end

  it 'should report all refs to self' do
    @refs.refs_to_self.should == 2
  end

  it 'should report self among the max' do
    @refs.max_keys.should be_include('a')
    @refs.max_keys.should be_include(Sexp.from_array([:lit, :self]))
  end

  it 'should report self as the max' do
    @refs.self_is_max?.should == true
  end
end

describe ObjectRefs, 'when self is not among the max' do
  before(:each) do
    @refs = ObjectRefs.new
    @refs.record_ref('a')
    @refs.record_ref('b')
    @refs.record_ref('a')
    @refs.record_ref('b')
  end

  it 'should report all refs to self' do
    @refs.refs_to_self.should == 0
  end

  it 'should not report self among the max' do
    @refs.max_keys.should be_include('a')
    @refs.max_keys.should be_include('b')
  end

  it 'should not report self as the max' do
    @refs.self_is_max?.should == false
  end
end
