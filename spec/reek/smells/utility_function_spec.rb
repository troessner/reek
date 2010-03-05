require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'utility_function')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe UtilityFunction do
  context 'with a singleton method' do
    ['self', 'local_call', '$global'].each do |receiver|
      it 'ignores the receiver' do
        "def #{receiver}.simple(arga) arga.to_s + arga.to_i end".should_not reek
      end
    end
  end
  context 'with no calls' do
    it 'does not report empty method' do
      'def simple(arga) end'.should_not reek
    end
    it 'does not report literal' do
      'def simple(arga) 3; end'.should_not reek
    end
    it 'does not report instance variable reference' do
      'def simple(arga) @yellow end'.should_not reek
    end
    it 'does not report vcall' do
      'def simple(arga) y end'.should_not reek
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
end

describe UtilityFunction do
  before(:each) do
    @source_name = 'loser'
    @detector = UtilityFunction.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'looking at the YAML' do
    before :each do
      src = <<EOS
def simple(arga)
  arga.b.c
end
EOS
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @detector.examine_context(@mctx)
      warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports the source' do
      @yaml.should match(/source:\s*#{@source_name}/)
    end
    it 'reports the class' do
      @yaml.should match(/\sclass:\s*LowCohesion/)
    end
    it 'reports the subclass' do
      @yaml.should match(/subclass:\s*UtilityFunction/)
    end
    it 'reports the line number of the method' do
      @yaml.should match(/lines:\s*- 1/)
    end
  end
end
