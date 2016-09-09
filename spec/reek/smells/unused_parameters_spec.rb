require_relative '../../spec_helper'
require_lib 'reek/smells/unused_parameters'

RSpec.describe Reek::Smells::UnusedParameters do
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

    expect(src).to reek_of(:UnusedParameters,
                           lines: [1],
                           name:  'bravo')
    expect(src).to reek_of(:UnusedParameters,
                           lines: [1],
                           name:  'charlie')
  end

  it 'reports nothing for no parameters' do
    expect('def alfa; end').not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing for used parameter' do
    expect('def alfa(bravo); bravo; end').not_to reek_of(:UnusedParameters)
  end

  it 'reports for 1 used and 2 unused parameter' do
    src = 'def alfa(bravo, charlie, delta); bravo end'

    expect(src).not_to reek_of(:UnusedParameters, name: 'bravo')
    expect(src).to reek_of(:UnusedParameters, name: 'charlie')
    expect(src).to reek_of(:UnusedParameters, name: 'delta')
  end

  it 'reports nothing for named parameters prefixed with _' do
    expect('def alfa(_bravo); end').not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using a parameter via self assignment' do
    expect('def alfa(bravo); bravo += 1; end').not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using a parameter on a rescue' do
    expect('def alfa(bravo = 3); puts "nothing"; rescue; retry if bravo -= 1 > 0; raise; end').
      not_to reek_of(:UnusedParameters)
  end

  context 'using super' do
    it 'reports nothing with implicit arguments' do
      expect('def alfa(*bravo); super; end').not_to reek_of(:UnusedParameters)
    end

    it 'reports something when explicitely passing no arguments' do
      expect('def alfa(*bravo); super(); end').to reek_of(:UnusedParameters)
    end

    it 'reports nothing when explicitely passing all arguments' do
      expect('def alfa(*bravo); super(*bravo); end').not_to reek_of(:UnusedParameters)
    end

    it 'reports nothing in a nested context' do
      expect('def alfa(*bravo); charlie(super); end').not_to reek_of(:UnusedParameters)
    end
  end

  context 'anonymous parameters' do
    it 'reports nothing for unused anonymous parameter' do
      expect('def alfa(_); end').not_to reek_of(:UnusedParameters)
    end

    it 'reports nothing for unused anonymous splatted parameter' do
      expect('def alfa(*); end').not_to reek_of(:UnusedParameters)
    end
  end

  context 'splatted parameters' do
    it 'reports nothing for used splatted parameter' do
      expect('def alfa(*bravo); bravo; end').not_to reek_of(:UnusedParameters)
    end

    it 'reports something when not using a keyword argument with splat' do
      expect('def alfa(**bravo); end').to reek_of(:UnusedParameters)
    end

    it 'reports nothing when using a keyword argument with splat' do
      expect('def alfa(**bravo); bravo; end').not_to reek_of(:UnusedParameters)
    end
  end
end
