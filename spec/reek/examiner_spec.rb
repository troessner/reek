require File.dirname(__FILE__) + '/../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'examiner')

include Reek

describe Sniffer do
  it 'detects smells in a file' do
    dirty_file = Dir['spec/samples/two_smelly_files/*.rb'][0]
    Examiner.new(File.new(dirty_file)).should be_smelly
  end

end
