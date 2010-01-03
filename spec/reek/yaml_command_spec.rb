require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/yaml_command'

include Reek

describe YamlCommand do
  before :each do
    @view = mock('view', :null_object => true)
  end

  context 'with no smells' do
    before :each do
      @sniffer = mock('sniffer')
      @sniffer.should_receive(:report_on)
      @cmd = YamlCommand.new([@sniffer])
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
    def report_on(listener)
      @smell = SmellWarning.new('UncommunicativeName', "self", 27, "self", true)
      listener.found_smell(@smell)
    end
    before :each do
      @cmd = YamlCommand.new([self])
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
