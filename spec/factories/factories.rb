FactoryGirl.define do
  factory :smell_dectector, class: Reek::Smells::SmellDetector do
    smell_class_name      'UtilityFunction'
    smell_sub_class_name  'UtilityFunction'
    source                ''

    initialize_with { new(source) }
  end

  factory :smell_warning, class: Reek::SmellWarning do
    smell_dectector
    context        'self'
    lines          [42]
    parameters     {}

    initialize_with { new(smell_dectector, context: context, lines: lines, parameters: parameters) }
  end
end
