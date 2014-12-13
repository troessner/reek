require 'spec_helper'
require 'reek/core/smell_configuration'

include Reek::Core

describe SmellConfiguration do
  it 'returns the default value when key not found' do
    cf = SmellConfiguration.new({})
    expect(cf.value('fred', nil, 27)).to eq(27)
  end

  context 'when overriding default configs' do
    before(:each) do
      @base_config = { 'enabled' => true, 'exclude' => [],
                       'reject' => [/^.$/, /[0-9]$/, /[A-Z]/],
                       'accept' => ['_'] }
      @smell_config = SmellConfiguration.new(@base_config)
    end

    it { expect(@smell_config.merge!({})).to eq(@base_config) }
    it { expect(@smell_config.merge!('enabled' => true)).to eq(@base_config) }
    it { expect(@smell_config.merge!('exclude' => [])).to eq(@base_config) }
    it { expect(@smell_config.merge!('accept' => ['_'])).to eq(@base_config) }
    it do
      @smell_config = @smell_config.merge!('reject' => [/^.$/, /[0-9]$/, /[A-Z]/])
      expect(@smell_config).to eq(@base_config)
    end
    it do
      @smell_config = @smell_config.merge!('enabled' => true, 'accept' => ['_'])
      expect(@smell_config).to eq(@base_config)
    end

    it 'should override single values' do
      @smell_config = @smell_config.merge!('enabled' => false)
      expect(@smell_config).to eq('enabled' => false, 'exclude' => [],
                                  'reject' => [/^.$/, /[0-9]$/, /[A-Z]/],
                                  'accept' => ['_'])
    end

    it 'should override arrays of values' do
      @smell_config = @smell_config.merge!('reject' => [/^.$/, /[3-9]$/])
      expect(@smell_config).to eq('enabled' => true,
                                  'exclude' => [],
                                  'reject' => [/^.$/, /[3-9]$/],
                                  'accept' => ['_'])
    end

    it 'should override multiple values' do
      expect(@smell_config.merge!('enabled' => false, 'accept' => [/[A-Z]$/])).to eq(
                           'enabled' => false, 'exclude' => [],
                           'reject' => [/^.$/, /[0-9]$/, /[A-Z]/],
                           'accept' => [/[A-Z]$/]
      )
    end
  end
end
