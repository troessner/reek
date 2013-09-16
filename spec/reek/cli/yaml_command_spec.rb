require 'spec_helper'
require 'reek/cli/yaml_command'

include Reek
include Reek::Cli

describe YamlCommand do
  before :each do
    @view = double('view').as_null_object
    @examiner = double('examiner')
  end

  context 'with no smells' do
    before :each do
      @examiner.should_receive(:smells).and_return([])
      @cmd = YamlCommand.new([@examiner])
    end

    it 'displays nothing on the view' do
      @view.should_not_receive(:output)
      @cmd.execute(@view)
    end

    it 'tells the view it succeeded' do
      @view.should_receive(:report_success)
      @cmd.execute(@view)
    end
  end

  context 'with smells' do
    before :each do
      @smell = SmellWarning.new('UncommunicativeName', "self", 27, "self")
      @examiner.should_receive(:smells).and_return([@smell])
      @cmd = YamlCommand.new([@examiner])
    end

    it 'displays the correct text on the view' do
      @view.should_receive(:output).with(/UncommunicativeName/)
      @cmd.execute(@view)
    end

    it 'tells the view it found smells' do
      @view.should_receive(:report_smells)
      @cmd.execute(@view)
    end
  end
end
