require 'spec_helper'

include Reek

describe Dir do
  it 'reports correct smells via the Dir matcher' do
    files = Dir['spec/samples/two_smelly_files/*.rb']
    expect(files).to reek
    expect(files).to reek_of(:UncommunicativeVariableName)
    expect(files).not_to reek_of(:LargeClass)
  end

  it 'copes with daft file specs' do
    expect(Dir['spec/samples/two_smelly_files/*/.rb']).not_to reek
  end

  it 'copes with empty array' do
    expect([]).not_to reek
  end
end
