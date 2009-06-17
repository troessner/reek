require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/report'
require 'reek/smells/duplication'

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

