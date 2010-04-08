require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'nested_iterators')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek::Smells

describe NestedIterators do

  it 'should report nested iterators in a method' do
    'def bad(fred) @fred.each {|item| item.each {|ting| ting.ting} } end'.should reek_only_of(:NestedIterators)
  end

  it 'should not report method with successive iterators' do
    src = <<EOS
def bad(fred)
  @fred.each {|item| item.each }
  @jim.each {|ting| ting.each }
end
EOS
    src.should_not reek
  end

  it 'should not report method with chained iterators' do
    src = <<EOS
def chained
  @sig.keys.sort_by { |xray| xray.to_s }.each { |min| md5 << min.to_s }
end
EOS
    src.should_not reek
  end

  it 'should report nested iterators only once per method' do
    src = <<EOS
def bad(fred)
  @fred.each {|item| item.each {|part| @joe.send} }
  @jim.each {|ting| ting.each {|piece| @hal.send} }
end
EOS
    src.should reek_only_of(:NestedIterators)
  end

  context 'when the allowed nesting depth is 3' do
    before :each do
      config = NestedIterators.default_config.merge(NestedIterators::MAX_ALLOWED_NESTING_KEY => 3)
      @detector = NestedIterators.new('depth-charge', config)
    end

    it 'should not report nested iterators 2 levels deep' do
      src = <<EOS
def bad(fred)
  @fred.each {|one| one.each {|two| two.two} }
end
EOS
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine(ctx)
      @detector.smells_found.should be_empty
    end

    it 'should not report nested iterators 3 levels deep' do
      src = <<EOS
def bad(fred)
  @fred.each {|one| one.each {|two| two.each {|three| three.three} } }
end
EOS
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine(ctx)
      @detector.smells_found.should be_empty
    end

    it 'should report nested iterators 4 levels deep' do
      src = <<EOS
def bad(fred)
  @fred.each {|one| one.each {|two| two.each {|three| three.each {|four| four.four} } } }
end
EOS
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine(ctx)
      smells = @detector.smells_found.to_a
      smells.length.should == 1
      smells[0].smell_class.should == NestedIterators::SMELL_CLASS
    end
  end
end

describe NestedIterators do
  before(:each) do
    @detector = NestedIterators.new('cuckoo')
  end

  it_should_behave_like 'SmellDetector'

  context 'find_deepest_iterators' do
    context 'with no iterators' do
      it 'returns an empty list' do
        src = 'def fred() nothing = true; end'
        source = src.to_reek_source
        sniffer = Sniffer.new(source)
        @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
        @detector.find_deepest_iterators(@mctx).should == []
      end
    end

    context 'with one iterator' do
      before :each do
        src = 'def fred() nothing.each {|item| item}; end'
        source = src.to_reek_source
        sniffer = Sniffer.new(source)
        mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
        @result = @detector.find_deepest_iterators(mctx)
      end
      it 'returns a depth of 1' do
        @result.should == []
      end
    end

    context 'with two non-nested iterators' do
      before :each do
        src = <<EOS
def fred()
  nothing.each do |item|
    item
  end
  again.each {|thing| }
end
EOS
        source = src.to_reek_source
        sniffer = Sniffer.new(source)
        mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
        @result = @detector.find_deepest_iterators(mctx)
      end
      it 'returns both iterators' do
        @result.length.should == 0
      end
    end

    context 'with one nested iterator' do
      before :each do
        src = <<EOS
def fred()
  nothing.each do |item|
    again.each {|thing| item }
  end
end
EOS
        source = src.to_reek_source
        sniffer = Sniffer.new(source)
        @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
        @result = @detector.find_deepest_iterators(@mctx)
      end
      it 'returns only the deepest iterator' do
        @result.length.should == 1
      end
      it 'has depth of 2' do
        @result[0][1].should == 2
      end
      it 'refers to the innermost exp' do
        @result[0][0].line.should == 3
      end

      context 'when reporting yaml' do
        before :each do
          @detector.examine_context(@mctx)
          warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
          @yaml = warning.to_yaml
        end
        it 'reports the depth' do
          @yaml.should match(/depth:\s*2/)
        end
        it 'reports the deepest line number' do
          @yaml.should match(/lines:[\s-]*3/)
        end
      end
    end
  end
end
