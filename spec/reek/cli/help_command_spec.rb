require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'cli', 'help_command')

include Reek::Cli

describe HelpCommand do
  before :each do
    @text = 'Piece of interesting text'
    @cmd = HelpCommand.new(@text)
    @view = mock('view', :null_object => true)
    @view.should_not_receive(:report_smells)
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
