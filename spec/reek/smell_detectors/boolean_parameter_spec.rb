require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/boolean_parameter'

RSpec.describe Reek::SmellDetectors::BooleanParameter do
  it 'reports the right values' do
    src = <<-EOS
      def alfa(bravo = true)
      end
    EOS

    expect(src).to reek_of(:BooleanParameter,
                           lines: [1],
                           context: 'alfa',
                           message: "has boolean parameter 'bravo'",
                           source: 'string',
                           parameter: 'bravo')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def alfa(bravo = true, charlie = true)
      end
    EOS

    expect(src).
      to reek_of(:BooleanParameter, lines: [1], context: 'alfa', parameter: 'bravo').
      and reek_of(:BooleanParameter, lines: [1], context: 'alfa', parameter: 'charlie')
  end

  context 'in a method' do
    it 'reports a parameter defaulted to false' do
      src = 'def alfa(bravo = false) end'
      expect(src).to reek_of(:BooleanParameter)
    end

    it 'reports two parameters defaulted to booleans in a mixed parameter list' do
      src = 'def alfa(bravo, charlie = true, delta = false, &echo) end'

      expect(src).to reek_of(:BooleanParameter, parameter: 'charlie').
        and reek_of(:BooleanParameter, parameter: 'delta').
        and not_reek_of(:BooleanParameter, parameter: 'bravo').
        and not_reek_of(:BooleanParameter, parameter: 'echo')
    end

    it 'reports keyword parameters defaulted to booleans' do
      src = 'def alfa(bravo: true, charlie: false) end'
      expect(src).
        to reek_of(:BooleanParameter, parameter: 'bravo').
        and reek_of(:BooleanParameter, parameter: 'charlie')
    end

    it 'does not report regular parameters' do
      src = 'def alfa(bravo, charlie) end'
      expect(src).not_to reek_of(:BooleanParameter)
    end

    it 'does not report array decomposition parameters' do
      src = 'def alfa((bravo, charlie)) end'
      expect(src).not_to reek_of(:BooleanParameter)
    end

    it 'does not report keyword parameters with no default' do
      src = 'def alfa(bravo:, charlie:) end'
      expect(src).not_to reek_of(:BooleanParameter)
    end

    it 'does not report keyword parameters with non-boolean default' do
      src = 'def alfa(bravo: 42, charlie: "32") end'
      expect(src).not_to reek_of(:BooleanParameter)
    end
  end

  context 'in a singleton method' do
    it 'reports a parameter defaulted to true' do
      src = 'def self.alfa(bravo = true) end'
      expect(src).to reek_of(:BooleanParameter)
    end

    it 'reports a parameter defaulted to false' do
      src = 'def self.alfa(bravo = false) end'
      expect(src).to reek_of(:BooleanParameter)
    end

    it 'reports two parameters defaulted to booleans' do
      src = 'def self.alfa(bravo, charlie = true, delta = false, &echo) end'

      expect(src).to reek_of(:BooleanParameter, parameter: 'charlie').
        and reek_of(:BooleanParameter, parameter: 'delta').
        and not_reek_of(:BooleanParameter, parameter: 'bravo').
        and not_reek_of(:BooleanParameter, parameter: 'echo')
    end
  end
end
