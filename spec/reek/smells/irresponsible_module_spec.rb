require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/class_context'
require 'reek/stop_context'
require 'reek/code_parser'
require 'reek/smells/irresponsible_module'
require 'spec/reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe IrresponsibleModule do
  ['class', 'module'].each do |unit|
    it "does not report a #{unit} having a comment" do
      src = <<EOS
# test #{unit}
#{unit} Responsible; end
EOS
      src.should_not reek
    end
    it "reports a #{unit} without a comment" do
      "#{unit} Responsible; end".should reek_only_of(:IrresponsibleModule, /Responsible/)
    end
    it "reports a #{unit} with an empty comment" do
      src = <<EOS
#
#
#  
#{unit} Responsible; end
EOS
      src.should reek_only_of(:IrresponsibleModule, /Responsible/)
    end
  end
end

describe IrresponsibleModule do
  before(:each) do
    @detector = IrresponsibleModule.new
  end

  it_should_behave_like 'SmellDetector'
end
