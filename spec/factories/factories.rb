FactoryGirl.define do
  factory :smell_detector, class: Reek::Smells::SmellDetector do
    skip_create
    smell_class      'LowCohesion'
    smell_sub_class  'FeatureEnvy'
    source           'dummy_file'

    initialize_with { new(source) }
  end

  factory :smell_warning, class: Reek::SmellWarning do
    skip_create
    smell_detector
    context        'self'
    lines          [42]
    message         'smell warning message'
    parameters     {}

    initialize_with do
      new(smell_detector, context: context,
                          lines: lines,
                          message: message,
                          parameters: parameters)
    end
  end
end
