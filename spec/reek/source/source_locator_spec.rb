require 'pathname'
require_relative '../../spec_helper'
require_lib 'reek/configuration/app_configuration'
require_lib 'reek/source/source_locator'

RSpec.describe Reek::Source::SourceLocator do
  describe '#sources' do
    context 'applied to hidden directories' do
      let(:path) { SAMPLES_PATH.join('source_with_hidden_directories') }
      let(:expected_paths) do
        [SAMPLES_PATH.join('source_with_hidden_directories/uncommunicative_parameter_name.rb')]
      end
      let(:paths_that_are_expected_to_be_ignored) do
        [SAMPLES_PATH.join('source_with_hidden_directories/.hidden/\
          uncommunicative_parameter_nameicative_method_name.rb')]
      end

      it 'does not scan hidden directories' do
        sources = described_class.new([path]).sources

        expect(sources).not_to include(*paths_that_are_expected_to_be_ignored)
        expect(sources).to eq expected_paths
      end
    end

    context 'exclude paths' do
      let(:configuration) do
        test_configuration_for(SAMPLES_PATH.join('configuration/with_excluded_paths.reek'))
      end
      let(:path) { SAMPLES_PATH.join('source_with_exclude_paths') }
      let(:paths_that_are_expected_to_be_ignored) do
        [
          SAMPLES_PATH.join('source_with_exclude_paths/ignore_me/uncommunicative_method_name.rb'),
          SAMPLES_PATH.join('source_with_exclude_paths/nested/' \
                            'ignore_me_as_well/irresponsible_module.rb')
        ]
      end

      it 'does not use excluded paths' do
        sources = described_class.new([path], configuration: configuration).sources
        expect(sources).not_to include(*paths_that_are_expected_to_be_ignored)

        expect(sources).to eq [
          SAMPLES_PATH.join('source_with_exclude_paths/nested/uncommunicative_parameter_name.rb')
        ]
      end
    end

    context 'non-Ruby paths' do
      let(:path) { SAMPLES_PATH.join('source_with_non_ruby_files') }
      let(:expected_sources) do
        [SAMPLES_PATH.join('source_with_non_ruby_files/uncommunicative_parameter_name.rb')]
      end
      let(:paths_that_are_expected_to_be_ignored) do
        [
          SAMPLES_PATH.join('source_with_non_ruby_files/gibberish'),
          SAMPLES_PATH.join('source_with_non_ruby_files/python_source.py')
        ]
      end

      it 'does only use Ruby source paths' do
        sources = described_class.new([path]).sources

        expect(sources).not_to include(*paths_that_are_expected_to_be_ignored)

        expect(sources).to eq expected_sources
      end
    end

    context 'passing "." or "./" as argument' do
      let(:expected_sources) do
        [Pathname.new('spec/spec_helper.rb'), Pathname.new('lib/reek.rb')]
      end

      it 'expands it correctly' do
        sources_for_dot       = described_class.new([Pathname.new('.')]).sources
        sources_for_dot_slash = described_class.new([Pathname.new('./')]).sources

        expect(sources_for_dot).to include(*expected_sources)
        expect(sources_for_dot).to eq(sources_for_dot_slash)
      end
    end
  end
end
