require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/stop_context'

include Reek
include Reek::Smells

describe StopContext do
  before :each do
    @stop = StopContext.new
  end

  context 'with a module that is not loaded' do
    it 'does not find the module' do
      @stop.find_module('Nobbles').should == nil
    end
    it 'does not find an unqualified class in the module' do
      @stop.find_module('HtmlExtension').should == nil
    end
  end

  context 'with a module that is loaded' do
    it 'finds the module' do
      @stop.find_module('Reek').name.should == 'Reek'
    end
  end
end
