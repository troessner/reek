require File.dirname(__FILE__) + '/../../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'cli')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'examiner')

include Reek

describe ReekCommand do
  before :each do
    @view = mock('view', :null_object => true)
  end

  context 'with smells' do
    before :each do
      examiner = Examiner.new('def x(); end')
      @cmd = ReekCommand.new([examiner], QuietReport, false)
    end

    it 'displays the correct text on the view' do
      @view.should_receive(:output).with(/Uncommunicative Name/)
      @cmd.execute(@view)
    end

    it 'tells the view it succeeded' do
      @view.should_receive(:report_smells)
      @cmd.execute(@view)
    end
  end

  context 'with no smells' do
    before :each do
      examiner = Examiner.new('def clean(); end')
      @cmd = ReekCommand.new([examiner], QuietReport, false)
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
