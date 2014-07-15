require 'spec_helper'
require 'reek/cli/help_command'

include Reek::Cli

describe HelpCommand do
  before :each do
    @text = 'Piece of interesting text'
    @cmd = HelpCommand.new(@text)
    @view = double('view').as_null_object
    expect(@view).not_to receive(:report_smells)
  end

  it 'displays the correct text on the view' do
    expect(@view).to receive(:output).with(@text)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    expect(@view).to receive(:report_success)
    @cmd.execute(@view)
  end
end
