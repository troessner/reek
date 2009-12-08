require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_comment'

include Reek

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
end
