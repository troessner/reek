require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'module_context')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'stop_context')

include Reek::Core

describe ModuleContext do
  it 'should report module name for smell in method' do
    'module Fred; def simple(x) true; end; end'.should reek_of(:UncommunicativeParameterName, /x/, /simple/)
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
end
