require File.dirname(__FILE__) + '/../spec_helper.rb'

include Reek

describe Sniffer do
  it 'detects smells in a file' do
    dirty_file = Dir['spec/samples/two_smelly_files/*.rb'][0]
    File.new(dirty_file).sniff.should be_smelly
  end
end
