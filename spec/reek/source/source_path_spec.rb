require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/reek/configuration/app_configuration'
require_relative '../../../lib/reek/source/source_path'

RSpec.describe Reek::Source::SourcePath do
  let(:source_path) { described_class.new(pathname, configuration: configuration) }
  let(:pathname) { Pathname.new(path) }
  let(:configuration) { Reek::Configuration::AppConfiguration.default }
  let(:path) { 'lib/reek/smells.rb' }

  describe '#to_s' do
    subject { source_path.to_s }

    it { is_expected.not_to be_nil }
    it { is_expected.to eq pathname.to_s }
  end

  describe '#read' do
    subject { source_path.read }

    it { is_expected.not_to be_nil }
    it { is_expected.to eq pathname.read }
  end

  describe '#relevant?' do
    subject { source_path.relevant? }

    context 'ruby file' do
      it { is_expected.to be true }

      context 'ignored' do
        let(:configuration) { Reek::Configuration::AppConfiguration.from_map(excluded_paths: [Pathname(path)]) }

        it { is_expected.to be false }
      end
    end

    context 'not ruby file' do
      let(:path) { 'Gemfile' }

      it { is_expected.to be false }
    end
  end

  describe '#ignored?' do
    subject { source_path.ignored? }

    context 'not ignored' do
      it { is_expected.to be false }
    end

    context 'excluded' do
      let(:configuration) { Reek::Configuration::AppConfiguration.from_map(excluded_paths: [Pathname(path)]) }

      it { is_expected.to be true }
    end

    context 'hidden' do
      let(:path) { '.rubocop.yml' }

      it { is_expected.to be true }
    end
  end

  describe '#relevant_children' do
    subject { source_path.relevant_children }

    context 'without block' do
      it { is_expected.to be_a_kind_of(Enumerator) }
    end

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
        expect(subject.to_a).not_to include(*paths_that_are_expected_to_be_ignored)
        expect(subject.to_a).to eq expected_paths
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
        expect(subject.to_a).not_to include(*paths_that_are_expected_to_be_ignored)

        expect(subject.to_a).to eq [
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
        expect(subject.to_a).not_to include(*paths_that_are_expected_to_be_ignored)
        expect(subject.to_a).to eq expected_sources
      end
    end

    context 'current directory' do
      let(:expected_sources) do
        [Pathname.new('spec/spec_helper.rb'), Pathname.new('lib/reek.rb')]
      end

      context 'passing . as an argument' do
        let(:path) { '.' }
        it 'expands it correctly' do
          expect(subject.to_a).to include(*expected_sources)
        end
      end

      context 'passing ./ as an argument' do
        let(:path) { './' }
        it 'expands it correctly' do
          expect(subject.to_a).to include(*expected_sources)
        end
      end
    end
  end
end
