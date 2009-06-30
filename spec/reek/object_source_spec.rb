require File.dirname(__FILE__) + '/../spec_helper.rb'

include Reek

describe Dir do
  it 'reports correct smells via the Dir matcher' do
    Dir['spec/samples/two_smelly_files/*.rb'].should reek_of(:UncommunicativeName)
  end

  it 'reports correct smells via SourceList' do
    src = Dir['spec/samples/two_smelly_files/*.rb'].to_source
    src.has_smell?(:UncommunicativeName).should be_true
  end
end
