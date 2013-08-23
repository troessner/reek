require 'spec_helper'
require 'reek/core/object_refs'

include Reek::Core

describe ObjectRefs do
  before(:each) do
    @refs = ObjectRefs.new
  end

  context 'when empty' do
    it 'should report no refs to self' do
      @refs.references_to(:self).should == 0
    end
  end

  context "with references to a, b, and a" do
    context 'with no refs to self' do
      before(:each) do
        @refs.record_reference_to('a')
        @refs.record_reference_to('b')
        @refs.record_reference_to('a')
      end

      it 'should report no refs to self' do
        @refs.references_to(:self).should == 0
      end

      it 'should report :a as the max' do
        @refs.max_keys.should == {'a' => 2}
      end

      it 'should not report self as the max' do
        @refs.self_is_max?.should == false
      end

      context "with one reference to self" do
        before(:each) do
          @refs.record_reference_to(:self)
        end

        it 'should report 1 ref to self' do
          @refs.references_to(:self).should == 1
        end

        it 'should not report self among the max' do
          @refs.max_keys.should include('a')
          @refs.max_keys.should_not include(:self)
        end

        it 'should not report self as the max' do
          @refs.self_is_max?.should == false
        end
      end
    end
  end

  context 'with many refs to self' do
    before(:each) do
      @refs.record_reference_to(:self)
      @refs.record_reference_to(:self)
      @refs.record_reference_to('a')
      @refs.record_reference_to(:self)
      @refs.record_reference_to('b')
      @refs.record_reference_to('a')
      @refs.record_reference_to(:self)
    end

    it 'should report all refs to self' do
      @refs.references_to(:self).should == 4
    end

    it 'should report self among the max' do
      @refs.max_keys.should == { :self => 4}
    end

    it 'should report self as the max' do
      @refs.self_is_max?.should == true
    end
  end

  context 'when self is not the only max' do
    before(:each) do
      @refs.record_reference_to('a')
      @refs.record_reference_to(:self)
      @refs.record_reference_to(:self)
      @refs.record_reference_to('b')
      @refs.record_reference_to('a')
    end

    it 'should report all refs to self' do
      @refs.references_to(:self).should == 2
    end

    it 'should report self among the max' do
      @refs.max_keys.should include('a')
      @refs.max_keys.should include(:self)
    end

    it 'should report self as the max' do
      @refs.self_is_max?.should == true
    end
  end

  context 'when self is not among the max' do
    before(:each) do
      @refs.record_reference_to('a')
      @refs.record_reference_to('b')
      @refs.record_reference_to('a')
      @refs.record_reference_to('b')
    end

    it 'should report all refs to self' do
      @refs.references_to(:self).should == 0
    end

    it 'should not report self among the max' do
      @refs.max_keys.should include('a')
      @refs.max_keys.should include('b')
    end

    it 'should not report self as the max' do
      @refs.self_is_max?.should == false
    end
  end
end

