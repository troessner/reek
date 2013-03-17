require 'spec_helper'

include Reek

describe Dir do
  it 'reports correct smells via the Dir matcher' do
    files = Dir['spec/samples/two_smelly_files/*.rb']
    files.should reek
    files.should reek_of(:UncommunicativeVariableName)
    files.should_not reek_of(:LargeClass)
  end

  it 'copes with daft file specs' do
    Dir["spec/samples/two_smelly_files/*/.rb"].should_not reek
  end

  it 'copes with empty array' do
    [].should_not reek
  end
end
