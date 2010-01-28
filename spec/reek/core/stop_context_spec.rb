require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'stop_context')

include Reek
include Reek::Core

describe StopContext do
  before :each do
    @stop = StopContext.new
  end

  context 'full_name' do
    it "reports full context" do
      @stop.full_name.should == ''
    end
  end
end
