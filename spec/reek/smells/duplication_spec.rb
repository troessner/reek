require File.dirname(__FILE__) + '/../../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'duplication')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'method_context')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'stop_context')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'configuration')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe Duplication, "repeated method calls" do
  it 'reports repeated call' do
    'def double_thing() @other.thing + @other.thing end'.should reek_only_of(:Duplication, /@other.thing/)
  end
  it 'reports repeated call to lvar' do
    'def double_thing(other) other[@thing] + other[@thing] end'.should reek_only_of(:Duplication, /other\[@thing\]/)
  end
  it 'reports call parameters' do
    'def double_thing() @other.thing(2,3) + @other.thing(2,3) end'.should reek_only_of(:Duplication, /@other.thing\(2, 3\)/)
  end
  it 'should report nested calls' do
    ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'
    ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
    ruby.should reek_of(:Duplication, /@other.thing.foo/)
  end
  it 'should ignore calls to new' do
    'def double_thing() @other.new + @other.new end'.should_not reek
  end
  it 'reports repeated assignment' do
    'def double_thing(thing) @other[thing] = true; @other[thing] = true; end'.should reek_only_of(:Duplication, /@other\[thing\] = true/)
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

describe Duplication do
  before(:each) do
    @source_name = 'copy-cat'
    @detector = Duplication.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'looking at the YAML' do
    before :each do
      src = <<EOS
def double_thing(other)
  other[@thing]
  not_the_sam(at = all)
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
    it 'reports the source' do
      @yaml.should match(/source:\s*#{@source_name}/)
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
      @yaml.should match(/lines:\s*- 2\s*- 4/)
    end
  end
end
