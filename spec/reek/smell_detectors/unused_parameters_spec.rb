require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/unused_parameters'

RSpec.describe Reek::SmellDetectors::UnusedParameters do
  it 'reports the right values' do
    src = <<-EOS
      def alfa(bravo)
      end
    EOS

    expect(src).to reek_of(:UnusedParameters,
                           lines:   [1],
                           context: 'alfa',
                           message: "has unused parameter 'bravo'",
                           source:  'string',
                           name:    'bravo')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def alfa(bravo, charlie)
      end
    EOS

    expect(src).
      to reek_of(:UnusedParameters, lines: [1], name: 'bravo').
      and reek_of(:UnusedParameters, lines: [1], name: 'charlie')
  end

  it 'reports nothing for no parameters' do
    src = 'def alfa; end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing for used parameter' do
    src = 'def alfa(bravo); bravo; end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports for 1 used and 2 unused parameter' do
    src = 'def alfa(bravo, charlie, delta); bravo end'

    expect(src).
      to not_reek_of(:UnusedParameters, name: 'bravo').
      and reek_of(:UnusedParameters, name: 'charlie').
      and reek_of(:UnusedParameters, name: 'delta')
  end

  it 'reports nothing for named parameters prefixed with _' do
    src = 'def alfa(_bravo); end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using a parameter via self assignment' do
    src = 'def alfa(bravo); bravo += 1; end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using a parameter on a rescue' do
    src = 'def alfa(bravo = 3); puts "nothing"; rescue; retry if bravo -= 1 > 0; raise; end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  context 'using super' do
    it 'reports nothing with implicit arguments' do
      src = 'def alfa(*bravo); super; end'
      expect(src).not_to reek_of(:UnusedParameters)
    end

    it 'reports something when explicitely passing no arguments' do
      src = 'def alfa(*bravo); super(); end'
      expect(src).to reek_of(:UnusedParameters)
    end

    it 'reports nothing when explicitely passing all arguments' do
      src = 'def alfa(*bravo); super(*bravo); end'
      expect(src).not_to reek_of(:UnusedParameters)
    end

    it 'reports nothing in a nested context' do
      src = 'def alfa(*bravo); charlie(super); end'
      expect(src).not_to reek_of(:UnusedParameters)
    end
  end

  context 'anonymous parameters' do
    it 'reports nothing for unused anonymous parameter' do
      src = 'def alfa(_); end'
      expect(src).not_to reek_of(:UnusedParameters)
    end

    it 'reports nothing for unused anonymous splatted parameter' do
      src = 'def alfa(*); end'
      expect(src).not_to reek_of(:UnusedParameters)
    end
  end

  context 'splatted parameters' do
    it 'reports nothing for used splatted parameter' do
      src = 'def alfa(*bravo); bravo; end'
      expect(src).not_to reek_of(:UnusedParameters)
    end

    it 'reports something when not using a keyword argument with splat' do
      src = 'def alfa(**bravo); end'
      expect(src).to reek_of(:UnusedParameters)
    end

    it 'reports nothing when using a keyword argument with splat' do
      src = 'def alfa(**bravo); bravo; end'
      expect(src).not_to reek_of(:UnusedParameters)
    end
  end
end
