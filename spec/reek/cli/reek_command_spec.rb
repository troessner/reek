require 'spec_helper'
require 'reek/cli/reek_command'
require 'reek/cli/report'
require 'reek/examiner'

include Reek
include Reek::Cli

describe ReekCommand do
  before :each do
    @view = double('view').as_null_object
  end

  context 'with smells' do
    before :each do
      examiner = Examiner.new('def x(); end')
      @cmd = ReekCommand.new(QuietReport.new, ['def x(); end'])
    end

    it 'displays the correct text on the view' do
      @view.should_receive(:output).with(/UncommunicativeMethodName/)
      @cmd.execute(@view)
    end

    it 'tells the view it succeeded' do
      @view.should_receive(:report_smells)
      @cmd.execute(@view)
    end
  end

  context 'with no smells' do
    before :each do
      @cmd = ReekCommand.new(QuietReport.new, ['def clean(); end'])
    end

    it 'displays nothing on the view' do
      @view.should_receive(:output).with('')
      @cmd.execute(@view)
    end

    it 'tells the view it succeeded' do
      @view.should_receive(:report_success)
      @cmd.execute(@view)
    end
  end
end
