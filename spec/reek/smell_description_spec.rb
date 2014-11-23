require 'spec_helper'
require 'reek/smell_description'

describe Reek::SmellDescription do
  let(:smell_class) { 'SmellClass' }
  let(:smell_subclass) { 'SmellySubclass' }
  let(:message) { 'smell message' }
  let(:details) { { 'key1' => 'value1', 'key2' => 'value2' } }

  let(:description) { described_class.new(smell_class, smell_subclass, message, details) }

  it "knows its smell class" do
    expect(description.smell_class).to eq smell_class
  end

  it "knows its smell subclass" do
    expect(description.smell_subclass).to eq smell_subclass
  end

  it "knows its smell message" do
    expect(description.message).to eq message
  end

  it "knows its details" do
    expect(description.details).to eq details
  end

  it "accesses its details through #[]" do
    expect(description['key1']).to eq 'value1'
    expect(description['key2']).to eq 'value2'
  end

  it "outputs the correct YAML" do
    expect(description.to_yaml).to eq <<-END
---
class: SmellClass
subclass: SmellySubclass
message: smell message
key1: value1
key2: value2
    END
  end
end
