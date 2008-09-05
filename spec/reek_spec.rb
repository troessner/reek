require File.dirname(__FILE__) + '/spec_helper.rb'

require 'reek'

describe Reek, "#analyse" do

  class ReekAnalyseInner1
    def short1(str) f(3);true end
    def long(arga, argb, argc, argd=4) f(3);27 end
  end

  class ReekAnalyseInner2
    def long(arga, argb, argc, argd) f(3);27 end
    def short2(str) f(3);true end
  end

  it 'should report Long Parameter List' do
    rpt = Reek.analyse(ReekAnalyseInner1)
    rpt.length.should == 1
  end

  it 'should report all Long Parameter Lists' do
    rpt = Reek.analyse(ReekAnalyseInner1, ReekAnalyseInner2)
    rpt.length.should == 2
  end

end
