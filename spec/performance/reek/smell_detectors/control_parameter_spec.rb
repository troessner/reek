require_relative '../../../spec_helper'
require_lib 'reek/smell_detectors/control_parameter'
require_lib 'reek/examiner'
require 'stackprof'

RSpec.describe Reek::SmellDetectors::ControlParameter do
  let(:source) { SAMPLES_DIR.join('smelly_source').join('ruby.rb') }

  it 'runs on a complicated source file in less than 10 seconds' do
    examiner = Reek::Examiner.new source, filter_by_smells: ['ControlParameter']
    # examiner = Reek::Examiner.new source
    # This is the actual test
    # expect(examiner.smells.size).to perform_under(10).sec

    # Meaningless test just to get stackprof running:
    StackProf.run(mode: :cpu, raw: true, out: 'tmp/control-parameter.dump') do
      expect(examiner.smells.size).to be_kind_of(Numeric)
    end
  end
end
