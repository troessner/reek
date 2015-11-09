require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_statements'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::TooManyStatements do
  it 'should not report short methods' do
    src = 'def short(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;end'
    expect(src).not_to reek_of(:TooManyStatements)
  end

  it 'should report long methods' do
    src = 'def long() alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end'
    expect(src).to reek_of(:TooManyStatements)
  end

  it 'should not report initialize' do
    src = <<-EOS
      def initialize(arga)
        alf = f(1); @bet = 2; @cut = 3; @dit = 4; @emp = 5; @fry = 6
      end
    EOS
    expect(src).not_to reek_of(:TooManyStatements)
  end

  it 'should report long inner block' do
    src = <<-EOS
      def long()
        f(3)
        self.each do |xyzero|
          xyzero = 1
          xyzero = 2
          xyzero = 3
          xyzero = 4
          xyzero = 5
          xyzero = 6
        end
      end
    EOS
    expect(src).to reek_of(:TooManyStatements)
  end
end

RSpec.describe Reek::Smells::TooManyStatements do
  let(:detector) { build(:smell_detector, smell_type: :TooManyStatements) }

  it_should_behave_like 'SmellDetector'

  context 'when the method has 30 statements' do
    let(:num_statements) { 30 }
    let(:smells) do
      ctx = double('method_context').as_null_object
      expect(ctx).to receive(:num_statements).and_return(num_statements)
      expect(ctx).to receive(:config_for).with(described_class).and_return({})
      detector.inspect(ctx)
    end

    it 'reports only 1 smell' do
      expect(smells.length).to eq(1)
    end

    it 'reports the number of statements' do
      expect(smells[0].parameters[:count]).to eq(num_statements)
    end

    it 'reports the correct smell sub class' do
      expect(smells[0].smell_type).to eq(described_class.smell_type)
    end
  end
end
