require_relative '../../../spec_helper'
require_lib 'reek/examiner'

RSpec.describe 'Runtime speed' do
  let(:source_directory) { SAMPLES_DIR.join('smelly_source') }

  it 'runs on our smelly sources in less than 5 seconds' do
    expect do
      Dir[source_directory.join('**/*.rb')].each do |entry|
        examiner = Reek::Examiner.new Pathname.new(entry)
        examiner.smells.size
      end
    end.to perform_under(5).sec
  end
end
