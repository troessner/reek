require File.dirname(__FILE__) + '/../spec_helper.rb'

include Reek

describe Dir do
  it 'reports correct smells via the Dir matcher' do
    Dir['spec/samples/two_smelly_files/*.rb'].should reek
    Dir['spec/samples/two_smelly_files/*.rb'].should reek_of(:UncommunicativeVariableName)
  end

  it 'copes with daft file specs' do
    Dir["spec/samples/two_smelly_files/*/.rb"].should_not reek
  end

  it 'copes with empty array' do
    [].should_not reek
  end
end
