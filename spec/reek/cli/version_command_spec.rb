require 'spec_helper'
require 'reek/cli/version_command'

include Reek
include Reek::Cli

describe VersionCommand do
  before :each do
    @text = 'Piece of interesting text'
    @cmd = VersionCommand.new(@text)
    @view = double('view').as_null_object
    expect(@view).not_to receive(:report_smells)
  end

  it 'displays the text on the view' do
    expect(@view).to receive(:output).with(/#{@text}/)
    @cmd.execute(@view)
  end

  it 'displays the Reek version on the view' do
    expect(@view).to receive(:output).with(/#{Reek::VERSION}/)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    expect(@view).to receive(:report_success)
    @cmd.execute(@view)
  end
end
