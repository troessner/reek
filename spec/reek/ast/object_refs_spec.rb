require_relative '../../spec_helper'
require_lib 'reek/ast/object_refs'

RSpec.describe Reek::AST::ObjectRefs do
  let(:refs) { described_class.new }

  context 'when empty' do
    it 'reports no refs to self' do
      expect(refs.references_to(:self)).to be_empty
    end
  end

  context 'with many refs to self' do
    before do
      refs.record_reference(name: :self)
      refs.record_reference(name: :self)
      refs.record_reference(name: :a)
      refs.record_reference(name: :self)
      refs.record_reference(name: :b)
      refs.record_reference(name: :a)
      refs.record_reference(name: :self)
    end

    it 'reports all refs to self' do
      expect(refs.references_to(:self).size).to eq(4)
    end

    it 'reports self among the max' do
      expect(refs.most_popular).to include(:self)
    end

    it 'reports self as the max' do
      expect(refs.self_is_max?).to eq(true)
    end
  end

  context 'when self is not the only max' do
    before do
      refs.record_reference(name: :a)
      refs.record_reference(name: :self)
      refs.record_reference(name: :self)
      refs.record_reference(name: :b)
      refs.record_reference(name: :a)
    end

    it 'reports all refs to self' do
      expect(refs.references_to(:self).size).to eq(2)
    end

    it 'reports self among the max' do
      expect(refs.most_popular).to include(:self)
    end

    it 'reports the other max among the max' do
      expect(refs.most_popular).to include(:a)
    end

    it 'reports self as the max' do
      expect(refs.self_is_max?).to eq(true)
    end
  end

  context 'when self is not recorded' do
    before do
      refs.record_reference(name: :a)
      refs.record_reference(name: :b)
      refs.record_reference(name: :a)
      refs.record_reference(name: :b)
    end

    it 'reports no refs to self' do
      expect(refs.references_to(:self).size).to eq(0)
    end

    it 'does not report self among the max' do
      expect(refs.most_popular).not_to include(:self)
    end

    it 'does not report self as the max' do
      expect(refs.self_is_max?).to eq(false)
    end
  end
end
