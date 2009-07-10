require File.dirname(__FILE__) + '/../spec_helper.rb'

include Reek

describe Sniffer do
  it 'detects smells in a file' do
    dirty_file = Dir['spec/samples/two_smelly_files/*.rb'][0]
    src = Source.from_path(dirty_file)
    sniffer = src.sniffer
    sniffer.should be_smelly
  end
end
