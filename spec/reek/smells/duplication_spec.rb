require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/configuration'
require 'reek/method_context'
require 'reek/stop_context'
require 'reek/smells/duplication'

include Reek
include Reek::Smells

describe Duplication, "repeated method calls" do
  it 'should report repeated call' do
    'def double_thing() @other.thing + @other.thing end'.should reek_only_of(:Duplication, /@other.thing/)
  end

  it 'should report repeated call to lvar' do
    'def double_thing(other) other[@thing] + other[@thing] end'.should reek_only_of(:Duplication, /other\[@thing\]/)
  end

  it 'should report call parameters' do
    'def double_thing() @other.thing(2,3) + @other.thing(2,3) end'.should reek_only_of(:Duplication, /@other.thing\(2, 3\)/)
  end

  it 'should report nested calls' do
    ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'.sniff
    ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
    ruby.should reek_of(:Duplication, /@other.thing.foo/)
  end

  it 'should ignore calls to new' do
    'def double_thing() @other.new + @other.new end'.should_not reek
  end
end

describe Duplication, "non-repeated method calls" do
  it 'should not report similar calls' do
    'def equals(other) other.thing == self.thing end'.should_not reek
  end

  it 'should respect call parameters' do
    'def double_thing() @other.thing(3) + @other.thing(2) end'.should_not reek
  end
end

require 'spec/reek/smells/smell_detector_shared'

describe Duplication do
  before(:each) do
    @detector = Duplication.new
  end

  it_should_behave_like 'SmellDetector'

  context 'looking at the YAML' do
    before :each do
      src = <<EOS
def double_thing(other)
  other[@thing]
  other[@thing]
end
EOS
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @detector.examine(@mctx)
      warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports the class' do
      @yaml.should match(/class:\s*Duplication/)
    end
    it 'reports the subclass' do
      @yaml.should match(/subclass:\s*DuplicateMethodCall/)
    end
    it 'reports the call' do
      @yaml.should match(/call:\s*other\[\@thing\]/)
    end
    it 'reports the correct lines' do
      pending
      @yaml.should match(/lines:\s*- 2\s*- 3/)
    end
  end
end
