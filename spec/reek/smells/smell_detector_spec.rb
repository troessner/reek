require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/report'
require 'reek/smells/duplication'
require 'reek/smells/large_class'

include Reek
include Reek::Smells

describe SmellDetector, 'when masked' do
  before(:each) do
    @detector = Duplication.new
    @detector.be_masked
    @detector.found(nil, 'help')
  end

  it 'reports smells as masked' do
    rpt = Report.new
    @detector.report_on(rpt)
    rpt.length.should == 0
    rpt.num_masked_smells.should == 1
  end
end

describe SmellDetector, 'configuration' do
#  it 'stays enabled when not disabled' do
#    @detector = LargeClass.new
#    @detector.should be_enabled
#    @detector.configure({'LargeClass' => {'max_methods' => 50}})
#    @detector.should be_enabled
#  end

  it 'becomes disabled when disabled' do
    @detector = LargeClass.new
    @detector.should be_enabled
    @detector.configure({'LargeClass' => {'enabled' => false}})
    @detector.should_not be_enabled
  end
end
