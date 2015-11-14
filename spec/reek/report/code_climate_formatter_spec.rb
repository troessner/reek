require_relative '../../spec_helper'
require_lib 'reek/report/code_climate_formatter'

RSpec.describe Reek::Report::CodeClimateFormatter, '#to_hash' do
  it "sets the type as 'issue'" do
    warning = FactoryGirl.build(:smell_warning)
    issue = Reek::Report::CodeClimateFormatter.new(warning)

    result = issue.to_hash

    expect(result).to include(type: 'issue')
  end

  it 'sets the category' do
    warning = FactoryGirl.build(:smell_warning)
    issue = Reek::Report::CodeClimateFormatter.new(warning)

    result = issue.to_hash

    expect(result).to include(categories: ['Complexity'])
  end

  it 'constructs a description based on the context and message' do
    warning = FactoryGirl.build(:smell_warning,
                                context: 'context foo',
                                message: 'message bar')
    issue = Reek::Report::CodeClimateFormatter.new(warning)

    result = issue.to_hash

    expect(result).to include(
      description: 'context foo message bar')
  end

  it 'sets a check name based on the smell detector' do
    warning = FactoryGirl.build(:smell_warning,
                                smell_detector: Reek::Smells::UtilityFunction.new)
    issue = Reek::Report::CodeClimateFormatter.new(warning)

    result = issue.to_hash

    expect(result).to include(check_name: 'LowCohesion/UtilityFunction')
  end

  it 'sets the location' do
    warning = FactoryGirl.build(:smell_warning,
                                lines: [1, 2],
                                source: 'a/ruby/source/file.rb')
    issue = Reek::Report::CodeClimateFormatter.new(warning)

    result = issue.to_hash

    expect(result).to include(
      location: {
        path: 'a/ruby/source/file.rb',
        lines: {
          begin: 1,
          end: 2
        }
      }
    )
  end
end
