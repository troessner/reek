require_relative '../../../spec_helper'
require_lib 'reek/report/code_climate/code_climate_fingerprint'

RSpec.describe Reek::Report::CodeClimateFingerprint do
  describe '#compute' do
    let(:computed) { described_class.new(warning).compute }

    shared_examples_for 'computes a fingerprint with no parameters' do
      let(:expected_fingerprint) { 'e68badd29db51c92363a7c6a2438d722' }
      let(:warning) do
        FactoryGirl.build(:smell_warning,
                          smell_detector: Reek::SmellDetectors::UtilityFunction.new,
                          context:        'alfa',
                          message:        "doesn't depend on instance state (maybe move it to another class?)",
                          lines:          lines,
                          source:         'a/ruby/source/file.rb')
      end

      it 'computes the fingerprint' do
        expect(computed).to eq expected_fingerprint
      end
    end

    context 'with code at a specific location' do
      let(:lines) { [1] }

      it_behaves_like 'computes a fingerprint with no parameters'
    end

    context 'with code at a different location' do
      let(:lines) { [5] }

      it_behaves_like 'computes a fingerprint with no parameters'
    end

    context 'when the fingerprint should not be computed' do
      let(:warning) do
        FactoryGirl.build(:smell_warning,
                          smell_detector: Reek::SmellDetectors::ManualDispatch.new,
                          context:        'Alfa#bravo',
                          message:        'manually dispatches method call',
                          lines:          [4],
                          source:         'a/ruby/source/file.rb')
      end

      it 'returns nil' do
        expect(computed).to be_nil
      end
    end

    shared_examples_for 'computes a fingerprint with identifying parameters' do
      let(:warning) do
        FactoryGirl.build(:smell_warning,
                          smell_detector: Reek::SmellDetectors::ClassVariable.new,
                          context:        'Alfa',
                          message:        "declares the class variable '@@#{name}'",
                          lines:          [4],
                          parameters:     { name: "@@#{name}" },
                          source:         'a/ruby/source/file.rb')
      end

      it 'computes the fingerprint' do
        expect(computed).to eq expected_fingerprint
      end
    end

    context 'when the name is one thing it has one fingerprint' do
      let(:name) { 'bravo' }
      let(:expected_fingerprint) { '9c3fd378178118a67e9509f87cae24f9' }

      it_behaves_like 'computes a fingerprint with identifying parameters'
    end

    context 'when the name is another thing it has another fingerprint' do
      let(:name) { 'echo' }
      let(:expected_fingerprint) { 'd2a6d2703ce04cca65e7300b7de4b89f' }

      it_behaves_like 'computes a fingerprint with identifying parameters'
    end

    shared_examples_for 'computes a fingerprint with identifying and non-identifying parameters' do
      let(:warning) do
        FactoryGirl.build(:smell_warning,
                          smell_detector: Reek::SmellDetectors::DuplicateMethodCall.new,
                          context:        "Alfa##{name}",
                          message:        "calls '#{name}' #{count} times",
                          lines:          lines,
                          parameters:     { name: "@@#{name}", count: count },
                          source:         'a/ruby/source/file.rb')
      end

      it 'computes the fingerprint' do
        expect(computed).to eq expected_fingerprint
      end
    end

    context 'when the parameters are provided' do
      let(:name) { 'bravo' }
      let(:count) { 5 }
      let(:lines) { [1, 7, 10, 13, 15] }
      let(:expected_fingerprint) { '238733f4f51ba5473dcbe94a43ec5400' }

      it_behaves_like 'computes a fingerprint with identifying and non-identifying parameters'
    end

    context 'when the non-identifying parameters change, it computes the same fingerprint' do
      let(:name) { 'bravo' }
      let(:count) { 9 }
      let(:lines) { [1, 7, 10, 13, 15, 17, 19, 20, 25] }
      let(:expected_fingerprint) { '238733f4f51ba5473dcbe94a43ec5400' }

      it_behaves_like 'computes a fingerprint with identifying and non-identifying parameters'
    end

    context 'but when the identifying parameters change, it computes a different fingerprint' do
      let(:name) { 'echo' }
      let(:count) { 5 }
      let(:lines) { [1, 7, 10, 13, 15] }
      let(:expected_fingerprint) { 'e0c35e9223cc19bdb9a04fb3e60573e1' }

      it_behaves_like 'computes a fingerprint with identifying and non-identifying parameters'
    end
  end
end
