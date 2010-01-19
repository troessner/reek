require File.dirname(__FILE__) + '/../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'module_context')
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'stop_context')

include Reek

describe ModuleContext do
  it 'should report module name for smell in method' do
    'module Fred; def simple(x) true; end; end'.should reek_of(:UncommunicativeParameterName, /x/, /simple/, /Fred/)
  end

  it 'should not report module with empty class' do
    '# module for test
module Fred
# module for test
 class Jim; end; end'.should_not reek
  end
end

describe ModuleContext do
  it 'should recognise global constant' do
    '# module for test
module ::Global
# module for test
 class Inside; end; end'.should_not reek
  end

  context 'full_name' do
    it "reports full context" do
      element = StopContext.new
      element = ModuleContext.new(element, 'mod', s(:module, :mod, nil))
      element.full_name.should == 'mod'
    end
  end

  it 'finds fq loaded class' do
    exp = [:class, :"Reek::Smells::LargeClass", nil]
    ctx = StopContext.new
    res = ModuleContext.resolve(exp[1], ctx)
    res[1].should == "LargeClass"
  end
end
