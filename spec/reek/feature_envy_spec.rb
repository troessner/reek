require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, "(Feature Envy)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report local method call' do
    @cchk.check_source('def simple(arga) f(17) end')
    @rpt.should be_empty
  end

  it 'should report message chain' do
    @cchk.check_source('def simple(arga) arga.b(arga) + arga.b(@fred) end')
    @rpt.length.should == 1
  end

  it 'should report highest affinity' do
    @cchk.check_source('def simple(arga) s1 = 0; arga.look(s1); process(s1) end')
    @rpt.length.should == 1
    @rpt[0].to_s.should match(/s1/)
  end

  it 'should report multiple affinities' do
    @cchk.check_source('def simple(arga) s1 = s2 = @thing = arga; arga.fire(s2); s2.fire(s1); arga.fire(s2) end')
    @rpt.length.should == 1
    @rpt[0].to_s.should match(/arga/)
    @rpt[0].to_s.should match(/s2/)
  end

  it 'should ignore global variables' do
    @cchk.check_source('def simple(arga) @s = ""; $s2.to_a; $s2.to_s; end')
    @rpt.length.should == 0
  end

  it 'should not report class methods' do
    @cchk.check_source('def simple() self.class.new.flatten_merge(self) end')
    @rpt.should be_empty
  end
end
