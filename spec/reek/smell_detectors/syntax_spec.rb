require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/syntax'

RSpec.describe Reek::SmellDetectors::Syntax do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
      edn
    EOS

    expect(src).to reek_of(:Syntax,
                           lines: [3],
                           context: 'This file',
                           message: 'has unexpected token $end',
                           source: 'string')
  end
end
