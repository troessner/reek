require_relative '../../lib/reek/smell_detectors'
require_relative '../../lib/reek/smell_detectors/base_detector'
require_relative '../../lib/reek/smell_warning'
require_relative '../../lib/reek/cli/options'

FactoryBot.define do
  factory :code_comment, class: 'Reek::CodeComment' do
    comment { '' }
    line { 1 }
    source { 'string' }
    initialize_with do
      new comment: comment,
          line: line,
          source: source
    end
  end
end
