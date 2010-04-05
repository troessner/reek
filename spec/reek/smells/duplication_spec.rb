require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'duplication')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'code_parser')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'sniffer')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe Duplication do
  before(:each) do
    @source_name = 'copy-cat'
    @detector = Duplication.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context "with repeated method calls" do
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
  end

  context 'with repeated attribute assignment' do
    it 'reports repeated assignment' do
      'def double_thing(thing) @other[thing] = true; @other[thing] = true; end'.should reek_only_of(:Duplication, /@other\[thing\] = true/)
    end
    it 'does not report multi-assignments' do
      src = <<EOS
def _parse ctxt
  ctxt.index, result = @ind, @result
  error, ctxt.index = @err, @err_ind
end
EOS
      src.should_not reek
    end
  end

  context 'when a smell is reported' do
    before :each do
      src = <<EOS
def double_thing(other)
  other[@thing]
  not_the_sam(at = all)
  other[@thing]
end
EOS
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine(ctx)
      smells = @detector.smells_found.to_a
      smells.length.should == 1
      @warning = smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the call' do
      @warning.smell['call'].should == 'other[@thing]'
    end
    it 'reports the correct lines' do
      @warning.lines.should == [2,4]
    end
  end

  context "non-repeated method calls" do
    it 'should not report similar calls' do
      'def equals(other) other.thing == self.thing end'.should_not reek
    end
    it 'should respect call parameters' do
      'def double_thing() @other.thing(3) + @other.thing(2) end'.should_not reek
    end
  end

  context "allowing up to 3 calls" do
    before :each do
      config = Duplication.default_config.merge(Duplication::MAX_ALLOWED_CALLS_KEY => 3)
      Duplication.should_receive(:default_config).and_return(config)
    end
    it 'does not report double calls' do
      'def double_thing() @other.thing + @other.thing end'.should_not reek
    end
    it 'does not report triple calls' do
      'def double_thing() @other.thing + @other.thing + @other.thing end'.should_not reek
    end
    it 'reports quadruple calls' do
      'def double_thing() @other.thing + @other.thing + @other.thing + @other.thing end'.should reek_only_of(:Duplication, /@other.thing/)
    end
  end

  context "allowing calls to some methods" do
    before :each do
      config = Duplication.default_config.merge(Duplication::ALLOW_CALLS_KEY => ['@some.thing',/puts/])
      Duplication.should_receive(:default_config).and_return(config)
    end
    it 'does not report calls to some methods' do
      'def double_some_thing() @some.thing + @some.thing end'.should_not reek
    end
    it 'reports calls to other methods' do
      'def double_other_thing() @other.thing + @other.thing end'.should reek_only_of(:Duplication, /@other.thing/)
    end
    it 'does not report calls to methods specifed with a regular expression' do
      'def double_puts() puts @other.thing; puts @other.thing end'.should reek_only_of(:Duplication, /@other.thing/)
    end
  end
end
