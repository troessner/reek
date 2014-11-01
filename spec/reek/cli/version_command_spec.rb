require 'spec_helper'
require 'reek/cli/version_command'

include Reek
include Reek::Cli

describe VersionCommand do
  before :each do
    @program_name = 'the_name_of_the_program'
    @parser = double('parser')
    expect(@parser).to receive(:program_name).and_return @program_name
    @cmd = VersionCommand.new(@parser)
    @view = double('view').as_null_object
  end

  it 'displays the text on the view' do
    expect(@view).to receive(:output).with(/#{@program_name}/)
    @cmd.execute(@view)
  end

  it 'displays the Reek version on the view' do
    expect(@view).to receive(:output).with(/#{Reek::VERSION}/)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    expect(@view).to receive(:report_success)
    expect(@view).not_to receive(:report_smells)
    @cmd.execute(@view)
  end
end
