require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'long_yield_list')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe LongYieldList do
  before(:each) do
    @source_name = 'oo la la'
    @detector = LongYieldList.new(@source_name)
    # SMELL: can't use the default config, because that contains an override,
    # which causes the mocked matches?() method to be called twice!!
  end

  it_should_behave_like 'SmellDetector'

  context 'yield' do
    it 'should not report yield with no parameters' do
      'def simple(arga, argb, &blk) f(3);yield; end'.should_not reek
    end
    it 'should not report yield with few parameters' do
      'def simple(arga, argb, &blk) f(3);yield a,b; end'.should_not reek
    end
    it 'should report yield with many parameters' do
      'def simple(arga, argb, &blk) f(3);yield arga,argb,arga,argb; end'.should reek_only_of(:LongYieldList, /simple/, /yields/, /4/)
    end
    it 'should not report yield of a long expression' do
      'def simple(arga, argb, &blk) f(3);yield(if @dec then argb else 5+3 end); end'.should_not reek
    end
  end

  context 'looking at the YAML' do
    before :each do
      src = <<EOS
def simple(arga, argb, &blk)
  f(3)
  yield(arga,argb,arga,argb)
  end
EOS
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @detector.examine_context(mctx)
      @warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the number of parameters' do
      @warning.smell['parameter_count'].should == 4
      # SMELL: many tests duplicate the names of the YAML fields
    end
    it 'reports the line number of the method' do
      @warning.lines.should == [3]
    end
  end
end
