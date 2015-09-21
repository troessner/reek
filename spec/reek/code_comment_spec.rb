require_relative '../spec_helper'
require_lib 'reek/code_comment'

RSpec.describe Reek::CodeComment do
  context 'with an empty comment' do
    let(:comment) { described_class.new('') }
    it 'is not descriptive' do
      expect(comment).not_to be_descriptive
    end
    it 'has an empty config' do
      expect(comment.config).to be_empty
    end
  end

  context 'comment checks' do
    it 'rejects an empty comment' do
      expect(described_class.new('#')).not_to be_descriptive
    end
    it 'rejects a 1-word comment' do
      expect(described_class.new("# fred\n#  ")).not_to be_descriptive
    end
    it 'accepts a 2-word comment' do
      expect(described_class.new('# fred here  ')).to be_descriptive
    end
    it 'accepts a multi-word comment' do
      comment = "# fred here \n# with \n   # biscuits "
      expect(described_class.new(comment)).to be_descriptive
    end
  end

  context 'comment config' do
    it 'parses hashed options' do
      comment = '# :reek:Duplication: { enabled: false }'
      config = described_class.new(comment).config
      expect(config).to include('Duplication')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
    end

    it 'parses multiple hashed options' do
      config = described_class.new('
        # :reek:Duplication: { enabled: false }
        # :reek:NestedIterators: { enabled: true }
      ').config
      expect(config).to include('Duplication', 'NestedIterators')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end

    it 'parses multiple hashed options on the same line' do
      config = described_class.new('
        #:reek:Duplication: { enabled: false } and :reek:NestedIterators: { enabled: true }
      ').config
      expect(config).to include('Duplication', 'NestedIterators')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end

    it 'parses multiple unhashed options on the same line' do
      comment = '# :reek:Duplication and :reek:NestedIterators'
      config = described_class.new(comment).config
      expect(config).to include('Duplication', 'NestedIterators')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_falsey
    end

    it 'disables the smell if no options are specifed' do
      config = described_class.new('# :reek:Duplication').config
      expect(config).to include('Duplication')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
    end

    it 'ignores smells after a space' do
      config = described_class.new('# :reek: Duplication').config
      expect(config).not_to include('Duplication')
    end
  end
end
