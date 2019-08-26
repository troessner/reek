require_relative '../../lib/reek/smell_detectors'
require_relative '../../lib/reek/smell_detectors/base_detector'
require_relative '../../lib/reek/smell_warning'
require_relative '../../lib/reek/cli/options'

FactoryBot.define do
  factory :smell_warning, class: Reek::SmellWarning do
    skip_create

    smell_type { 'FeatureEnvy' }
    source { 'dummy_file' }
    lines { [42] }
    message { 'smell warning message' }
    parameters { {} }
    context { 'self' }

    initialize_with do
      new(smell_type,
          source: source,
          context: context,
          lines: lines,
          message: message,
          parameters: parameters)
    end
  end

  factory :code_comment, class: Reek::CodeComment do
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
