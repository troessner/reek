require 'spec_helper'
require 'reek/cli/help_command'

include Reek::Cli

describe HelpCommand do
  before :each do
    @help_text = 'Piece of interesting text'
    @parser = double('parser')
    allow(@parser).to receive(:help_text).and_return @help_text
    @cmd = HelpCommand.new(@parser)
    @view = double('view').as_null_object
  end

  it 'displays the correct text on the view' do
    expect(@view).to receive(:output).with(@help_text)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    expect(@view).not_to receive(:report_smells)
    expect(@view).to receive(:report_success)
    @cmd.execute(@view)
  end
end
