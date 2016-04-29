require_relative '../../lib/reek/smell_detectors'
require_relative '../../lib/reek/smell_detectors/base_detector'
require_relative '../../lib/reek/smell_warning'
require_relative '../../lib/reek/cli/options'

FactoryGirl.define do
  factory :method_context, class: Reek::Context::MethodContext do
    skip_create
    transient do
      source 'def foo; end'
    end

    initialize_with do
      new(nil, Reek::Source::SourceCode.from(source).syntax_tree)
    end
  end

  factory :smell_detector, class: Reek::SmellDetectors::BaseDetector do
    skip_create
    transient do
      smell_type 'FeatureEnvy'
    end

    initialize_with do
      ::Reek::SmellDetectors.const_get(smell_type).new
    end
  end

  factory :smell_warning, class: Reek::SmellWarning do
    skip_create
    smell_detector
    context 'self'
    source 'dummy_file'
    lines [42]
    message 'smell warning message'
    parameters { {} }

    initialize_with do
      new(smell_detector,
          source: source,
          context: context,
          lines: lines,
          message: message,
          parameters: parameters)
    end
  end

  factory :code_comment, class: Reek::CodeComment do
    comment ''
    line 1
    source 'string'
    initialize_with do
      new comment: comment,
          line: line,
          source: source
    end
  end
end
