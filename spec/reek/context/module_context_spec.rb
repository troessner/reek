require_relative '../../spec_helper'
require_relative '../../../lib/reek/context/module_context'
require_relative '../../../lib/reek/context/root_context'

RSpec.describe Reek::Context::ModuleContext do
  it 'should report module name for smell in method' do
    expect('
      module Fred
        def simple(x) x + 1; end
      end
    ').to reek_of(:UncommunicativeParameterName, name: 'x')
  end

  it 'should not report module with empty class' do
    expect('# module for test
module Fred
# module for test
 class Jim; end; end').not_to reek
  end
end

RSpec.describe Reek::Context::ModuleContext do
  it 'should recognise global constant' do
    expect('# module for test
module ::Global
# module for test
 class Inside; end; end').not_to reek
  end
end
