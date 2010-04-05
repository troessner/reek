require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'source', 'code_comment')

include Reek::Source

describe CodeComment do
  context 'comment checks' do
    it 'rejects no comment' do
      CodeComment.new('').is_descriptive?.should be_false
    end
    it 'rejects an empty comment' do
      CodeComment.new('#').is_descriptive?.should be_false
    end
    it 'rejects a 1-word comment' do
      CodeComment.new("# fred\n#  ").is_descriptive?.should be_false
    end
    it 'accepts a 2-word comment' do
      CodeComment.new('# fred here  ').is_descriptive?.should be_true
    end
    it 'accepts a multi-word comment' do
      CodeComment.new("# fred here \n# with \n   # biscuits ").is_descriptive?.should be_true
    end
  end
  context 'comment config' do
    it 'parses hashed options' do
      CodeComment.new("# :reek:Duplication: { enabled: false }").config.should include('Duplication')
    end
    it 'parses multiple hashed options' do
      CodeComment.new("# :reek:Duplication: { enabled: false }\n:reek:NestedIterators: { enabled: true }").config.should include('Duplication','NestedIterators')
    end
  end
end
