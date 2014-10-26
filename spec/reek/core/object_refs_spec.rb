require 'spec_helper'
require 'reek/core/object_refs'

include Reek::Core

describe ObjectRefs do
  before(:each) do
    @refs = ObjectRefs.new
  end

  context 'when empty' do
    it 'should report no refs to self' do
      expect(@refs.references_to(:self)).to eq(0)
    end
  end

  context 'with references to a, b, and a' do
    context 'with no refs to self' do
      before(:each) do
        @refs.record_reference_to('a')
        @refs.record_reference_to('b')
        @refs.record_reference_to('a')
      end

      it 'should report no refs to self' do
        expect(@refs.references_to(:self)).to eq(0)
      end

      it 'should report :a as the max' do
        expect(@refs.max_keys).to eq('a' => 2)
      end

      it 'should not report self as the max' do
        expect(@refs.self_is_max?).to eq(false)
      end

      context 'with one reference to self' do
        before(:each) do
          @refs.record_reference_to(:self)
        end

        it 'should report 1 ref to self' do
          expect(@refs.references_to(:self)).to eq(1)
        end

        it 'should not report self among the max' do
          expect(@refs.max_keys).to include('a')
          expect(@refs.max_keys).not_to include(:self)
        end

        it 'should not report self as the max' do
          expect(@refs.self_is_max?).to eq(false)
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
      expect(@refs.references_to(:self)).to eq(4)
    end

    it 'should report self among the max' do
      expect(@refs.max_keys).to eq(self: 4)
    end

    it 'should report self as the max' do
      expect(@refs.self_is_max?).to eq(true)
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
      expect(@refs.references_to(:self)).to eq(2)
    end

    it 'should report self among the max' do
      expect(@refs.max_keys).to include('a')
      expect(@refs.max_keys).to include(:self)
    end

    it 'should report self as the max' do
      expect(@refs.self_is_max?).to eq(true)
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
      expect(@refs.references_to(:self)).to eq(0)
    end

    it 'should not report self among the max' do
      expect(@refs.max_keys).to include('a')
      expect(@refs.max_keys).to include('b')
    end

    it 'should not report self as the max' do
      expect(@refs.self_is_max?).to eq(false)
    end
  end
end
