require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/class_checker'
require 'reek/report'

include Reek

describe ClassChecker, "(Large Class)" do

  class BigOne
    26.times do |i|
      define_method "m#{i}".to_sym do
        @melting
      end
    end
  end

  before(:each) do
    @rpt = Report.new
    @cchk = ClassChecker.new(@rpt)
  end

  it 'should not report short class' do
    class ShortClass
      def m1() @m1; end
      def m2() @m2; end
      def m3() @m3; end
      def m4() @m4; end
      def m5() @m5; end
      def m6() @m6; end
    end
    @cchk.check_object(ShortClass)
    @rpt.should be_empty
  end

  it 'should report large class' do
    @cchk.check_object(BigOne)
    @rpt.length.should == 1
  end

  it 'should report class name' do
    @cchk.check_object(BigOne)
    @rpt[0].report.should match(/BigOne/)
  end
end
