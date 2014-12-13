require 'spec_helper'
require 'reek/core/module_context'
require 'reek/core/stop_context'

include Reek::Core

describe ModuleContext do
  it 'should report module name for smell in method' do
    expect('
      module Fred
        def simple(x) x + 1; end
      end
    ').to reek_of(:UncommunicativeParameterName, /x/, /simple/)
  end

  it 'should not report module with empty class' do
    expect('# module for test
module Fred
# module for test
 class Jim; end; end').not_to reek
  end
end

describe ModuleContext do
  it 'should recognise global constant' do
    expect('# module for test
module ::Global
# module for test
 class Inside; end; end').not_to reek
  end
end
