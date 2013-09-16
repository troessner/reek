require 'spec_helper'
require 'reek/smells/utility_function'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe UtilityFunction do
  before(:each) do
    @source_name = 'loser'
    @detector = UtilityFunction.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'with a singleton method' do
    ['self', 'local_call', '$global'].each do |receiver|
      it 'ignores the receiver' do
        src = "def #{receiver}.simple(arga) arga.to_s + arga.to_i end"
        ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
        @detector.examine_context(ctx).should be_empty
      end
    end
  end
  context 'with no calls' do
    it 'does not report empty method' do
      src = 'def simple(arga) end'
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine_context(ctx).should be_empty
    end
    it 'does not report literal' do
      'def simple() 3; end'.should_not reek
    end
    it 'does not report instance variable reference' do
      'def simple() @yellow end'.should_not reek
    end
    it 'does not report vcall' do
      'def simple() y end'.should_not reek
    end
    it 'does not report references to self' do
      'def into; self; end'.should_not reek
    end
    it 'recognises an ivar reference within a block' do
      'def clean(text) text.each { @fred = 3} end'.should_not reek
    end
    it 'copes with nil superclass' do
      '# clean class for testing purposes
class Object; def is_maybe?() false end end'.should_not reek
    end
  end

  context 'with only one call' do
    it 'does not report a call to a parameter' do
      'def simple(arga) arga.to_s end'.should_not reek_of(:UtilityFunction, /simple/)
    end
    it 'does not report a call to a constant' do
      'def simple(arga) FIELDS[arga] end'.should_not reek
    end
  end

  context 'with two or more calls' do
    it 'reports two calls' do
      'def simple(arga) arga.to_s + arga.to_i end'.should reek_of(:UtilityFunction, /simple/)
    end
    it 'counts a local call in a param initializer' do
      'def simple(arga=local) arga.to_s end'.should_not reek_of(:UtilityFunction)
    end
    it 'should count usages of self'do
      'def <=>(other) Options[:sort_order].compare(self, other) end'.should_not reek
    end
    it 'should count self reference within a dstr' do
      'def as(alias_name); "#{self} as #{alias_name}".to_sym; end'.should_not reek
    end
    it 'should count calls to self within a dstr' do
      'def to_sql; "\'#{self.gsub(/\'/, "\'\'")}\'"; end'.should_not reek
    end
    it 'should report message chain' do
      'def simple(arga) arga.b.c end'.should reek_of(:UtilityFunction, /simple/)
    end

    it 'does not report a method that calls super' do
      'def child(arg) super; arg.to_s; end'.should_not reek
    end

    it 'should recognise a deep call' do
      src = <<EOS
# clean class for testing purposes
  class Red
    def deep(text)
      text.each { |mod| atts = shelve(mod) }
    end

    def shelve(val)
      @shelf << val
    end
  end
EOS
      src.should_not reek
    end
  end

  context 'when a smells is reported' do
    before :each do
      src = <<EOS
def simple(arga)
  arga.b.c
end
EOS
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @warning = @detector.examine_context(mctx)[0]   # SMELL: too cumbersome!
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the line number of the method' do
      @warning.lines.should == [1]
    end
  end
end
