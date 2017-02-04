require_relative '../spec_helper'
require_lib 'reek/code_comment'

RSpec.describe Reek::CodeComment do
  context 'with an empty comment' do
    let(:comment) { FactoryGirl.build(:code_comment, comment: '') }

    it 'is not descriptive' do
      expect(comment).not_to be_descriptive
    end

    it 'has an empty config' do
      expect(comment.config).to be_empty
    end
  end

  context 'comment checks' do
    it 'rejects an empty comment' do
      comment = FactoryGirl.build(:code_comment, comment: '#')
      expect(comment).not_to be_descriptive
    end

    it 'rejects a 1-word comment' do
      comment = FactoryGirl.build(:code_comment, comment: "# alpha\n#  ")
      expect(comment).not_to be_descriptive
    end

    it 'accepts a 2-word comment' do
      comment = FactoryGirl.build(:code_comment, comment: '# alpha bravo  ')
      expect(comment).to be_descriptive
    end

    it 'accepts a multi-word comment' do
      comment = FactoryGirl.build(:code_comment, comment: "# alpha bravo \n# charlie \n   # delta ")
      expect(comment).to be_descriptive
    end
  end

  context 'good comment config' do
    it 'parses hashed options' do
      comment = '# :reek:DuplicateMethodCall { enabled: false }'
      config = FactoryGirl.build(:code_comment,
                                 comment: comment).config

      expect(config).to include('DuplicateMethodCall')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
    end

    it "supports hashed options with the legacy separator ':' after the smell detector" do
      comment = '# :reek:DuplicateMethodCall: { enabled: false }'
      config = FactoryGirl.build(:code_comment,
                                 comment: comment).config

      expect(config).to include('DuplicateMethodCall')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
    end

    it 'parses multiple hashed options' do
      comment = <<-EOF
        # :reek:DuplicateMethodCall { enabled: false }
        # :reek:NestedIterators { enabled: true }
      EOF
      config = FactoryGirl.build(:code_comment, comment: comment).config

      expect(config).to include('DuplicateMethodCall', 'NestedIterators')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end

    it 'parses multiple hashed options on the same line' do
      comment = <<-EOF
        #:reek:DuplicateMethodCall { enabled: false } and :reek:NestedIterators { enabled: true }
      EOF
      config = FactoryGirl.build(:code_comment, comment: comment).config

      expect(config).to include('DuplicateMethodCall', 'NestedIterators')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end

    it 'parses multiple unhashed options on the same line' do
      comment = '# :reek:DuplicateMethodCall and :reek:NestedIterators'
      config = FactoryGirl.build(:code_comment, comment: comment).config

      expect(config).to include('DuplicateMethodCall', 'NestedIterators')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_falsey
    end

    it 'disables the smell if no options are specifed' do
      comment = '# :reek:DuplicateMethodCall'
      config = FactoryGirl.build(:code_comment, comment: comment).config

      expect(config).to include('DuplicateMethodCall')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
    end

    it 'ignores smells after a space' do
      config = FactoryGirl.build(:code_comment,
                                 comment: '# :reek: DuplicateMethodCall').config
      expect(config).not_to include('DuplicateMethodCall')
    end

    it 'removes the configuration options from the comment' do
      original_comment = <<-EOF
        # Actual
        # :reek:DuplicateMethodCall { enabled: false }
        # :reek:NestedIterators { enabled: true }
        # comment
      EOF
      comment = FactoryGirl.build(:code_comment, comment: original_comment)

      expect(comment.send(:sanitized_comment)).to eq('Actual comment')
    end
  end
end

RSpec.describe Reek::CodeComment::CodeCommentValidator do
  context 'bad detector' do
    it 'raises BadDetectorInCommentError' do
      expect do
        FactoryGirl.build(:code_comment,
                          comment: '# :reek:DoesNotExist')
      end.to raise_error(Reek::Errors::BadDetectorInCommentError)
    end
  end

  context 'unparsable detector configuration' do
    it 'raises GarbageDetectorConfigurationInCommentError' do
      expect do
        comment = '# :reek:UncommunicativeMethodName { thats: a: bad: config }'
        FactoryGirl.build(:code_comment, comment: comment)
      end.to raise_error(Reek::Errors::GarbageDetectorConfigurationInCommentError)
    end
  end

  describe 'validating configuration keys' do
    context 'basic options mispelled' do
      it 'raises BadDetectorConfigurationKeyInCommentError' do
        expect do
          # exclude -> exlude and enabled -> nabled
          comment = '# :reek:UncommunicativeMethodName { exlude: alfa, nabled: true }'
          FactoryGirl.build(:code_comment, comment: comment)
        end.to raise_error(Reek::Errors::BadDetectorConfigurationKeyInCommentError)
      end
    end

    context 'basic options not mispelled' do
      it 'does not raise' do
        expect do
          comment = '# :reek:UncommunicativeMethodName { exclude: alfa, enabled: true }'
          FactoryGirl.build(:code_comment, comment: comment)
        end.not_to raise_error
      end

      it 'does not raise on regexps' do
        expect do
          comment = '# :reek:UncommunicativeMethodName { exclude: !ruby/regexp /alfa/ }'
          FactoryGirl.build(:code_comment, comment: comment)
        end.not_to raise_error
      end
    end

    context 'unknown custom options' do
      it 'raises BadDetectorConfigurationKeyInCommentError' do
        expect do
          # max_copies -> mx_copies and min_clump_size -> mn_clump_size
          comment = '# :reek:DataClump { mx_copies: 4, mn_clump_size: 3 }'
          FactoryGirl.build(:code_comment, comment: comment)
        end.to raise_error(Reek::Errors::BadDetectorConfigurationKeyInCommentError)
      end
    end

    context 'valid custom options' do
      it 'does not raise' do
        expect do
          comment = '# :reek:DataClump { max_copies: 4, min_clump_size: 3 }'
          FactoryGirl.build(:code_comment, comment: comment)
        end.not_to raise_error
      end
    end
  end
end
