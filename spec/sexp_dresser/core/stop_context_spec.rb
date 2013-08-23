require 'spec_helper'
require 'sexp_dresser/core/stop_context'

include SexpDresser
include SexpDresser::Core

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
