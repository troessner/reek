require File.dirname(__FILE__) + '/../../spec_helper.rb'


require 'spec/reek/code_checks'

include CodeChecks
include Reek
include Reek::Smells

describe CodeParser, "(Utility Function)" do

  before(:each) do
    @rpt = Report.new
    @cchk = CodeParser.new(@rpt)
  end

  it 'should not report attrset' do
    class Fred
      attr_writer :xyz
    end
    @cchk.check_object(Fred)
    @rpt.should be_empty
  end

  check 'should count usages of self',
    'def <=>(other) Options[:sort_order].compare(self, other) end', []
  check 'should count self reference within a dstr',
    'def as(alias_name); "#{self} as #{alias_name}".to_sym; end', []
  check 'should count calls to self within a dstr',
    'def to_sql; "\'#{self.gsub(/\'/, "\'\'")}\'"; end', []
  check 'should report simple parameter call', 'def simple(arga) arga.to_s end', [[/simple/, /instance state/]]
  check 'should report message chain', 'def simple(arga) arga.b.c end', [[/simple/, /instance state/]]
  
  it 'should not report overriding methods' do
    class Father
      def thing(ff); @kids = 0; end
    end
    class Son < Father
      def thing(ff); ff; end
    end
    CodeParser.new(@rpt).check_object(Son)
    @rpt.should be_empty
  end

    source = <<EOS
class Cache
  class << self
    def create_unless_known(attributes)
      Cache.create(attributes) unless Cache.known?
    end
  end
end
EOS
  check 'should not report class method', source, [], 'bug'
  
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
  check 'should recognise a deep call', src, []
end

describe UtilityFunction, 'should only report a method containing a call' do
  check 'should not report empty method', 'def simple(arga) end', []
  check 'should not report literal', 'def simple(arga) 3; end', []
  check 'should not report instance variable reference',  'def simple(arga) @yellow end', []
  check 'should not report vcall', 'def simple(arga) y end', []
  check 'should not report references to self', 'def into; self; end', []
end
