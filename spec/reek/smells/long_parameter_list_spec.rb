require_relative '../../spec_helper'
require_lib 'reek/context/code_context'
require_lib 'reek/smells/long_parameter_list'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::LongParameterList do
  context 'for methods with few parameters' do
    it 'should report nothing for no parameters' do
      expect('def simple; f(3);true; end').not_to reek_of(:LongParameterList)
    end

    it 'should report nothing for 1 parameter' do
      expect('def simple(yep) f(3);true end').not_to reek_of(:LongParameterList)
    end

    it 'should report nothing for 2 parameters' do
      expect('def simple(yep,zero) f(3);true end').not_to reek_of(:LongParameterList)
    end

    it 'should not count an optional block' do
      src = 'def simple(alpha, yep, zero, &opt) f(3); true end'
      expect(src).not_to reek_of(:LongParameterList)
    end

    it 'should not report inner block with too many parameters' do
      src = '
        def simple(yep,zero)
          m[3]; rand(34); f.each { |arga, argb, argc, argd| true}
        end
      '
      expect(src).not_to reek_of(:LongParameterList)
    end

    describe 'and default values' do
      it 'should report nothing for 1 parameter' do
        expect('def simple(zero=nil) f(3);false end').not_to reek_of(:LongParameterList)
      end

      it 'should report nothing for 2 parameters with 1 default' do
        source = 'def simple(yep, zero=nil) f(3); false end'
        expect(source).not_to reek_of(:LongParameterList)
      end

      it 'should report nothing for 2 defaulted parameters' do
        source = 'def simple(yep=4, zero=nil) f(3); false end'
        expect(source).not_to reek_of(:LongParameterList)
      end
    end
  end

  describe 'for methods with too many parameters' do
    it 'should report 4 parameters' do
      src = 'def simple(arga, argb, argc, argd) f(3);true end'
      expect(src).to reek_of(:LongParameterList, count: 4)
    end

    it 'should report 8 parameters' do
      src = 'def simple(arga, argb, argc, argd,arge, argf, argg, argh) f(3);true end'
      expect(src).to reek_of(:LongParameterList, count: 8)
    end

    describe 'and default values' do
      it 'should report 3 with 1 defaulted' do
        src = 'def simple(polly, queue, yep, zero=nil) f(3);false end'
        expect(src).to reek_of(:LongParameterList, count: 4)
      end

      it 'should report with 3 defaulted' do
        src = 'def simple(aarg, polly=2, yep=:truth, zero=nil) f(3);false end'
        expect(src).to reek_of(:LongParameterList, count: 4)
      end
    end
  end
end

RSpec.describe Reek::Smells::LongParameterList do
  let(:detector) { build(:smell_detector, smell_type: :LongParameterList) }

  it_should_behave_like 'SmellDetector'

  context 'when a smell is reported' do
    let(:warning) do
      src = <<-EOS
        def badguy(arga, argb, argc, argd)
          f(3)
          true
        end
      EOS
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      detector.inspect(ctx).first
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the number of parameters' do
      expect(warning.parameters[:count]).to eq(4)
    end

    it 'reports the name' do
      expect(warning.parameters[:name]).to eq(:badguy)
    end

    it 'reports the line number of the method' do
      expect(warning.lines).to eq([1])
    end

    it 'reports the message' do
      expect(warning.message).to eq('has 4 parameters')
    end
  end
end
