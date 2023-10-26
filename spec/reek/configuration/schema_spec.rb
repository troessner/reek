require_relative '../../spec_helper'
require_lib 'reek/configuration/schema'

RSpec.shared_examples_for 'all detectors present' do |path|
  it 'contains a rule for the Attribute detector' do
    expect(schema.info.dig(*(path + [:Attribute]))).not_to be_nil
  end

  it 'contains a rule for the BooleanParameter detector' do
    expect(schema.info.dig(*(path + [:BooleanParameter]))).not_to be_nil
  end

  it 'contains a rule for the ClassVariable detector' do
    expect(schema.info.dig(*(path + [:ClassVariable]))).not_to be_nil
  end

  it 'contains a rule for the ControlParameter detector' do
    expect(schema.info.dig(*(path + [:ControlParameter]))).not_to be_nil
  end

  it 'contains a rule for the DataClump detector' do
    expect(schema.info.dig(*(path + [:DataClump]))).not_to be_nil
  end

  it 'contains a rule for the DuplicateMethodCall detector' do
    expect(schema.info.dig(*(path + [:DuplicateMethodCall]))).not_to be_nil
  end

  it 'contains a rule for the FeatureEnvy detector' do
    expect(schema.info.dig(*(path + [:FeatureEnvy]))).not_to be_nil
  end

  it 'contains a rule for the InstanceVariableAssumption detector' do
    expect(schema.info.dig(*(path + [:InstanceVariableAssumption]))).not_to be_nil
  end

  it 'contains a rule for the IrresponsibleModule detector' do
    expect(schema.info.dig(*(path + [:IrresponsibleModule]))).not_to be_nil
  end

  it 'contains a rule for the LongParameterList detector' do
    expect(schema.info.dig(*(path + [:LongParameterList]))).not_to be_nil
  end

  it 'contains a rule for the LongYieldList detector' do
    expect(schema.info.dig(*(path + [:LongYieldList]))).not_to be_nil
  end

  it 'contains a rule for the ManualDispatch detector' do
    expect(schema.info.dig(*(path + [:ManualDispatch]))).not_to be_nil
  end

  it 'contains a rule for the MissingSafeMethod detector' do
    expect(schema.info.dig(*(path + [:MissingSafeMethod]))).not_to be_nil
  end

  it 'contains a rule for the ModuleInitialize detector' do
    expect(schema.info.dig(*(path + [:ModuleInitialize]))).not_to be_nil
  end

  it 'contains a rule for the NestedIterators detector' do
    expect(schema.info.dig(*(path + [:NestedIterators]))).not_to be_nil
  end

  it 'contains a rule for the NilCheck detector' do
    expect(schema.info.dig(*(path + [:NilCheck]))).not_to be_nil
  end

  it 'contains a rule for the RepeatedConditional detector' do
    expect(schema.info.dig(*(path + [:RepeatedConditional]))).not_to be_nil
  end

  it 'contains a rule for the SubclassedFromCoreClass detector' do
    expect(schema.info.dig(*(path + [:SubclassedFromCoreClass]))).not_to be_nil
  end

  it 'contains a rule for the TooManyConstants detector' do
    expect(schema.info.dig(*(path + [:TooManyConstants]))).not_to be_nil
  end

  it 'contains a rule for the TooManyInstanceVariables detector' do
    expect(schema.info.dig(*(path + [:TooManyInstanceVariables]))).not_to be_nil
  end

  it 'contains a rule for the TooManyMethods detector' do
    expect(schema.info.dig(*(path + [:TooManyMethods]))).not_to be_nil
  end

  it 'contains a rule for the TooManyStatements detector' do
    expect(schema.info.dig(*(path + [:TooManyStatements]))).not_to be_nil
  end

  it 'contains a rule for the UncommunicativeMethodName detector' do
    expect(schema.info.dig(*(path + [:UncommunicativeMethodName]))).not_to be_nil
  end

  it 'contains a rule for the UncommunicativeModuleName detector' do
    expect(schema.info.dig(*(path + [:UncommunicativeModuleName]))).not_to be_nil
  end

  it 'contains a rule for the UncommunicativeParameterName detector' do
    expect(schema.info.dig(*(path + [:UncommunicativeParameterName]))).not_to be_nil
  end

  it 'contains a rule for the UncommunicativeVariableName detector' do
    expect(schema.info.dig(*(path + [:UncommunicativeVariableName]))).not_to be_nil
  end

  it 'contains a rule for the UnusedParameters detector' do
    expect(schema.info.dig(*(path + [:UnusedParameters]))).not_to be_nil
  end

  it 'contains a rule for the UnusedPrivateMethod detector' do
    expect(schema.info.dig(*(path + [:UnusedPrivateMethod]))).not_to be_nil
  end

  it 'contains a rule for the UtilityFunction detector' do
    expect(schema.info.dig(*(path + [:UtilityFunction]))).not_to be_nil
  end
end

RSpec.describe Reek::Configuration::Schema do
  describe '#schema' do
    let(:schema) { described_class.schema }

    it 'contains rules for detectors' do
      expect(schema.info[:keys]).to include(Reek::DETECTORS_KEY.to_sym)
    end

    it_behaves_like 'all detectors present', [:keys, Reek::DETECTORS_KEY.to_sym, :keys]

    it 'contains rules for directories' do
      expect(schema.info[:keys]).to include(Reek::DIRECTORIES_KEY.to_sym)
    end

    it 'contains rules for exclude_paths' do
      expect(schema.info[:keys]).to include(Reek::EXCLUDE_PATHS_KEY.to_sym)
    end

    it 'does not create unnecessary directories rules' do
      expect(schema.info.dig(:keys, :directories, :keys)).to be_empty
    end

    context 'with directories' do
      let(:schema) { described_class.schema(['app/controllers']) }

      it_behaves_like 'all detectors present', [:keys, Reek::DIRECTORIES_KEY.to_sym, :keys, :'app/controllers', :keys]
    end
  end
end
