require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'examiner')

include Reek

describe Examiner do
  it 'detects smells in a file' do
    dirty_file = Dir['spec/samples/two_smelly_files/*.rb'][0]
    Examiner.new(File.new(dirty_file)).should be_smelly
  end
  it 'doesnt match a fragrant String' do
    examiner = Examiner.new('def good() true; end')
    examiner.smells.should == []
  end
  it 'matches a smelly String' do
    Examiner.new('def fine() y = 4; end').smells.length.should == 1
  end

  context 'checking code in a Dir' do
    it 'matches a smelly Dir' do
      smelly_dir = Dir['spec/samples/all_but_one_masked/*.rb']
      Examiner.new(smelly_dir).smells.length.should == 1
    end
    it 'doesnt match a fragrant Dir' do
      clean_dir = Dir['spec/samples/three_clean_files/*.rb']
      Examiner.new(clean_dir).smells.length.should == 0
    end
  end

  context 'checking code in a File' do
    it 'matches a smelly File' do
      smelly_file = File.new(Dir['spec/samples/all_but_one_masked/d*.rb'][0])
      Examiner.new(smelly_file).smells.length.should == 1
    end

    it 'doesnt match a fragrant File' do
      clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
      Examiner.new(clean_file).smells.length.should == 0
    end
  end

end
