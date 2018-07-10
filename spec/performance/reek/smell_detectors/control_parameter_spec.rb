require_relative '../../../spec_helper'
require_lib 'reek/smell_detectors/control_parameter'
require_lib 'reek/examiner'
require 'stackprof'
require 'ruby-prof'

RSpec.describe Reek::SmellDetectors::ControlParameter do
  let(:source) { SAMPLES_DIR.join('smelly_source').join('ruby.rb') }

  xit 'runs on a complicated source file in less than 10 seconds' do
    examiner = Reek::Examiner.new source, filter_by_smells: ['ControlParameter']
    expect(examiner.smells.size).to perform_under(10).sec
  end

  xit 'debugs via RubyProf' do
    RubyProf.start

    examiner = Reek::Examiner.new source, filter_by_smells: ['ControlParameter']
    expect(examiner.smells.size).to be_kind_of(Numeric)

    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT)
  end

  xit 'debugs via StackProf' do
    StackProf.run(mode: :cpu, raw: true, out: 'tmp/control-parameter.dump') do
      examiner = Reek::Examiner.new source, filter_by_smells: ['ControlParameter']
      expect(examiner.smells.size).to be_kind_of(Numeric)
    end
  end
end
