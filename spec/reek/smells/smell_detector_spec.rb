require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/report'
require 'reek/smells/duplication'
require 'reek/smells/large_class'

include Reek
include Reek::Smells

describe SmellDetector, 'configuration' do
  before:each do
    @detector = LongMethod.new
  end

  it 'adopts new max_statements value' do
    @detector.configure_with('max_statements' => 25)
    @detector.max_statements.should == 25
  end
end

describe SmellDetector, 'when copied' do
  before :each do
    @detector = LongMethod.new
    @copy = @detector.copy
  end

  it 'should have the same state' do
    @copy.max_statements.should == @detector.max_statements
  end

  it 'should change independently of its parent' do
    default_max = @detector.max_statements
    @copy.configure_with('max_statements' => 25)
    @detector.max_statements.should == default_max
  end
end

describe SmellDetector, 'when masked' do
  before(:each) do
    @detector = Duplication.new
    @detector.be_masked
    @detector.found(nil, 'help')
  end

  it 'reports smells as masked' do
    rpt = Report.new(Sniffer.new)
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
