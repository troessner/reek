require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'warning_collector')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smell_warning')

include Reek::Core

describe WarningCollector do
  before(:each) do
    @collector = WarningCollector.new
  end

  context 'when empty' do
    it 'reports no warnings' do
      @collector.warnings.should == []
    end
  end

  context 'with one warning' do
    before :each do
      @warning = Reek::SmellWarning.new('ControlCouple', 'fred', [1,2,3], 'hello')
      @collector.found_smell(@warning)
    end
    it 'reports that warning' do
      @collector.warnings.should == [@warning]
    end
  end
end
