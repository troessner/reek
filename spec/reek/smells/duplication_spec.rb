require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'duplication')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'code_parser')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'sniffer')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe Duplication do

  context 'when a smell is reported' do
    before :each do
      @source_name = 'copy-cat'
      @detector = Duplication.new(@source_name)
      src = <<EOS
def double_thing(other)
  other[@thing]
  not_the_sam(at = all)
  other[@thing]
end
EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine_context(ctx)
      smells.length.should == 1
      @warning = smells[0]
    end

    it_should_behave_like 'SmellDetector'
    it_should_behave_like 'common fields set correctly'

    it 'reports the call' do
      @warning.smell[Duplication::CALL_KEY].should == 'other[@thing]'
    end
    it 'reports the correct lines' do
      @warning.lines.should == [2,4]
    end
  end

  context "with repeated method calls" do
    it 'reports repeated call' do
      src = 'def double_thing() @other.thing + @other.thing end'
      src.should smell_of(Duplication, Duplication::CALL_KEY => '@other.thing')
    end
    it 'reports repeated call to lvar' do
      src = 'def double_thing(other) other[@thing] + other[@thing] end'
      src.should smell_of(Duplication, Duplication::CALL_KEY => 'other[@thing]')
    end
    it 'reports call parameters' do
      src = 'def double_thing() @other.thing(2,3) + @other.thing(2,3) end'
      src.should smell_of(Duplication, Duplication::CALL_KEY => '@other.thing(2, 3)')
    end
    it 'should report nested calls' do
      src = 'def double_thing() @other.thing.foo + @other.thing.foo end'
      src.should smell_of(Duplication, {Duplication::CALL_KEY => '@other.thing'},
                                       {Duplication::CALL_KEY => '@other.thing.foo'})
    end
    it 'should ignore calls to new' do
      src = 'def double_thing() @other.new + @other.new end'
      src.should_not smell_of(Duplication)
    end
  end

  context 'with repeated attribute assignment' do
    it 'reports repeated assignment' do
      src = 'def double_thing(thing) @other[thing] = true; @other[thing] = true; end'
      src.should smell_of(Duplication, Duplication::CALL_KEY => '@other[thing] = true')
    end
    it 'does not report multi-assignments' do
      src = <<EOS
def _parse ctxt
  ctxt.index, result = @ind, @result
  error, ctxt.index = @err, @err_ind
end
EOS
      src.should_not smell_of(Duplication)
    end
  end

  context "non-repeated method calls" do
    it 'should not report similar calls' do
      src = 'def equals(other) other.thing == self.thing end'
      src.should_not smell_of(Duplication)
    end
    it 'should respect call parameters' do
      src = 'def double_thing() @other.thing(3) + @other.thing(2) end'
      src.should_not smell_of(Duplication)
    end
  end

  context "allowing up to 3 calls" do
    before :each do
      @config = {Duplication::MAX_ALLOWED_CALLS_KEY => 3}
    end
    it 'does not report double calls' do
      src = 'def double_thing() @other.thing + @other.thing end'
      src.should_not smell_of(Duplication).with_config(@config)
    end
    it 'does not report triple calls' do
      src = 'def double_thing() @other.thing + @other.thing + @other.thing end'
      src.should_not smell_of(Duplication).with_config(@config)
    end
    it 'reports quadruple calls' do
      src = 'def double_thing() @other.thing + @other.thing + @other.thing + @other.thing end'
      src.should smell_of(Duplication, {Duplication::CALL_KEY => '@other.thing', Duplication::OCCURRENCES_KEY => 4}).with_config(@config)
    end
  end

  context "allowing calls to some methods" do
    before :each do
      @config = {Duplication::ALLOW_CALLS_KEY => ['@some.thing',/puts/]}
    end
    it 'does not report calls to some methods' do
      src = 'def double_some_thing() @some.thing + @some.thing end'
      src.should_not smell_of(Duplication).with_config(@config)
    end
    it 'reports calls to other methods' do
      src = 'def double_other_thing() @other.thing + @other.thing end'
      src.should smell_of(Duplication, {Duplication::CALL_KEY => '@other.thing'}).with_config(@config)
    end
    it 'does not report calls to methods specifed with a regular expression' do
      src = 'def double_puts() puts @other.thing; puts @other.thing end'
      src.should smell_of(Duplication, {Duplication::CALL_KEY => '@other.thing'}).with_config(@config)
    end
  end
end
