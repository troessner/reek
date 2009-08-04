require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smell_warning'
require 'reek/smells/feature_envy'

include Reek

describe SmellWarning, 'equality' do
  before :each do
    @first = SmellWarning.new(Smells::FeatureEnvy.new, "self", "self", true)
    @second = SmellWarning.new(Smells::FeatureEnvy.new, "self", "self", false)
  end

  it 'should hash equal when the smell is the same' do
    @first.hash.should == @second.hash
  end

  it 'should compare equal when the smell is the same' do
    @first.should == @second
  end

  it 'should compare equal when using <=>' do
    (@first <=> @second).should == 0
  end
  
  class CountingReport
    attr_reader :masked, :non_masked
    def initialize
      @masked = @non_masked = 0
    end
    def <<(sw)
      @non_masked += 1
    end
    
    def record_masked_smell(sw)
      @masked += 1
    end
  end

  it 'reports as masked when masked' do
    rpt = CountingReport.new
    @first.report_on(rpt)
    rpt.masked.should == 1
    rpt.non_masked.should == 0
  end

  it 'reports as non-masked when non-masked' do
    rpt = CountingReport.new
    @second.report_on(rpt)
    rpt.masked.should == 0
    rpt.non_masked.should == 1
  end
end
