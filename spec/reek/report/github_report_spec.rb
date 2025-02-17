# frozen_string_literal: true

require_relative '../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/json_report'

RSpec.describe Reek::Report::GithubReport do
  let(:instance) do
    described_class.new
  end

  let(:examiner) do
    Reek::Examiner.new(source)
  end

  context 'with empty source' do
    let(:source) do
      ''
    end

    it 'prints empty string' do
      instance.add_examiner(examiner)
      expect { instance.show }.not_to output.to_stdout
    end
  end

  context 'with smelly source' do
    let(:source) do
      <<~RUBY
        def simple(a)
          a[3]
        end
      RUBY
    end

    it 'prints smells as GitHub Workflow commands' do
      instance.add_examiner(examiner)
      expect { instance.show }.to output(
        <<~TEXT
          ::warning file=string,line=1::UncommunicativeParameterName: simple has the parameter name 'a'
          ::warning file=string,line=1::UtilityFunction: simple doesn't depend on instance state (maybe move it to another class?)
        TEXT
      ).to_stdout
    end
  end
end
