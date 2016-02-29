require_relative '../../spec_helper'
require_lib 'reek/report/code_climate/code_climate_formatter'

RSpec.describe Reek::Report::CodeClimateFormatter, '#render' do
  let(:warning) do
    FactoryGirl.build(:smell_warning,
                      smell_detector: Reek::Smells::UtilityFunction.new,
                      context:        'context foo',
                      message:        'message bar',
                      lines:          [1, 2],
                      source:         'a/ruby/source/file.rb')
  end
  let(:rendered) { Reek::Report::CodeClimateFormatter.new(warning).render }

  it "sets the type as 'issue'" do
    expect(rendered).to match(/\"type\":\"issue\"/)
  end

  it 'sets the category' do
    expect(rendered).to match(/\"categories\":\[\"Complexity\"\]/)
  end

  it 'constructs a description based on the context and message' do
    expect(rendered).to match(/\"description\":\"context foo message bar\"/)
  end

  it 'sets a check name based on the smell detector' do
    expect(rendered).to match(/\"check_name\":\"UtilityFunction\"/)
  end

  it 'sets the location' do
    expect(rendered).to match(%r{\"location\":{\"path\":\"a/ruby/source/file.rb\",\"lines\":{\"begin\":1,\"end\":2}}})
  end

  it 'sets a content based on the smell detector' do
    expect(rendered).to match(
      /\"body\":\"A _Utility Function_ is any instance method that has no dependency on the state of the instance.\\n\"/
    )
  end

  it 'sets remediation points based on the smell detector' do
    expect(rendered).to match(/\"remediation_points\":250000/)
  end
end
