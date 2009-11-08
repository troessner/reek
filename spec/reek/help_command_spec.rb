require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/help_command'

include Reek

describe HelpCommand do
  before :each do
    @text = 'Piece of interesting text'
    @cmd = HelpCommand.new(@text)
    @view = mock('view', :null_object => true)
  end

  it 'displays the correct text on the view' do
    @view.should_receive(:output).with(@text)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    @view.should_receive(:report_success)
    @cmd.execute(@view)
  end
end
