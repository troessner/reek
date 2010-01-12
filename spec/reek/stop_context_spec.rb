require File.dirname(__FILE__) + '/../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'stop_context')

include Reek
include Reek::Smells

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
