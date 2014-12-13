require 'spec_helper'
require 'reek/source/code_comment'

include Reek::Source

describe CodeComment do
  context 'with an empty comment' do
    before :each do
      @comment = CodeComment.new('')
    end
    it 'is not descriptive' do
      expect(@comment).not_to be_descriptive
    end
    it 'has an empty config' do
      expect(@comment.config).to be_empty
    end
  end

  context 'comment checks' do
    it 'rejects an empty comment' do
      expect(CodeComment.new('#')).not_to be_descriptive
    end
    it 'rejects a 1-word comment' do
      expect(CodeComment.new("# fred\n#  ")).not_to be_descriptive
    end
    it 'accepts a 2-word comment' do
      expect(CodeComment.new('# fred here  ')).to be_descriptive
    end
    it 'accepts a multi-word comment' do
      expect(CodeComment.new("# fred here \n# with \n   # biscuits ")).to be_descriptive
    end
  end

  context 'comment config' do
    it 'parses hashed options' do
      config = CodeComment.new('# :reek:Duplication: { enabled: false }').config
      expect(config).to include('Duplication')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
    end
    it 'parses hashed options with ruby names' do
      config = CodeComment.new('# :reek:nested_iterators: { enabled: true }').config
      expect(config).to include('NestedIterators')
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end
    it 'parses multiple hashed options' do
      config = CodeComment.new('
        # :reek:Duplication: { enabled: false }
        :reek:nested_iterators: { enabled: true }
      ').config
      expect(config).to include('Duplication', 'NestedIterators')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end
    it 'parses multiple hashed options on the same line' do
      config = CodeComment.new('
        #:reek:Duplication: { enabled: false } and :reek:nested_iterators: { enabled: true }
      ').config
      expect(config).to include('Duplication', 'NestedIterators')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end
    it 'parses multiple unhashed options on the same line' do
      config = CodeComment.new('# :reek:Duplication and :reek:nested_iterators').config
      expect(config).to include('Duplication', 'NestedIterators')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_falsey
    end
    it 'disables the smell if no options are specifed' do
      config = CodeComment.new('# :reek:Duplication').config
      expect(config).to include('Duplication')
      expect(config['Duplication']).to include('enabled')
      expect(config['Duplication']['enabled']).to be_falsey
    end
    it 'ignores smells after a space' do
      config = CodeComment.new('# :reek: Duplication').config
      expect(config).not_to include('Duplication')
    end
  end
end
