require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/utility_function'

include Reek
include Reek::Smells

describe UtilityFunction do

  before(:each) do
    @rpt = Report.new
    @cchk = CodeParser.new(@rpt, SmellConfig.new.smell_listeners)
  end

  it 'should not report attrset' do
    class Fred
      attr_writer :xyz
    end
    @cchk.check_object(Fred)
    @rpt.should be_empty
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
  it 'should report simple parameter call' do
    'def simple(arga) arga.to_s end'.should reek_of(:UtilityFunction, /simple/)
  end
  it 'should report message chain' do
    'def simple(arga) arga.b.c end'.should reek_of(:UtilityFunction, /simple/)
  end
  
  it 'should not report overriding methods' do
    class Father
      def thing(ff); @kids = 0; end
    end
    class Son < Father
      def thing(ff); ff; end
    end
    @cchk.check_object(Son)
    @rpt.should be_empty
  end

  it 'should not report class method' do
    pending('bug')
    source = <<EOS
class Cache
  class << self
    def create_unless_known(attributes)
      Cache.create(attributes) unless Cache.known?
    end
  end
end
EOS
    source.should_not reek
  end
  
  it 'should recognise a deep call' do
    src = <<EOS
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

describe UtilityFunction, 'should only report a method containing a call' do
  it 'should not report empty method' do
    'def simple(arga) end'.should_not reek
  end
  it 'should not report literal' do
    'def simple(arga) 3; end'.should_not reek
  end
  it 'should not report instance variable reference' do
    'def simple(arga) @yellow end'.should_not reek
  end
  it 'should not report vcall' do
    'def simple(arga) y end'.should_not reek
  end
  it 'should not report references to self' do
    'def into; self; end'.should_not reek
  end
end
