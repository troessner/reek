require 'pathname'
require_relative '../../spec_helper'
require_lib 'reek/configuration/app_configuration'
require_lib 'reek/source/source_locator'

RSpec.describe Reek::Source::SourceLocator do
  describe '#sources' do
    context 'applied to hidden directories' do
      let(:path) { SAMPLES_PATH.join('source_with_hidden_directories') }

      let(:expected_paths) do
        [path.join('uncommunicative_parameter_name.rb')]
      end

      let(:paths_that_are_expected_to_be_ignored) do
        [path.join('.hidden/uncommunicative_method_name.rb')]
      end

      it 'does not scan hidden directories' do
        sources = described_class.new([path]).sources

        expect(sources).not_to include(*paths_that_are_expected_to_be_ignored)
      end

      it 'scans directories that are not hidden' do
        sources = described_class.new([path]).sources

        expect(sources).to match_array expected_paths
      end
    end

    # rubocop:disable RSpec/NestedGroups
    context 'exclude paths' do
      let(:configuration) do
        test_configuration_for(CONFIG_PATH.join('with_excluded_paths.reek'))
      end

      let(:options) { instance_double('Reek::CLI::Options', force_exclusion?: false) }

      context 'when the path is absolute' do
        let(:path) do
          SAMPLES_PATH.join('source_with_exclude_paths',
                            'ignore_me',
                            'uncommunicative_method_name.rb').expand_path
        end

        context 'and options.force_exclusion? is true' do
          before do
            allow(options).to receive(:force_exclusion?).and_return(true)
          end

          it 'excludes this file' do
            sources = described_class.new([path], configuration: configuration, options: options).sources
            expect(sources).not_to include(path)
          end
        end

        context 'and options.force_exclusion? is false' do
          before do
            allow(options).to receive(:force_exclusion?).and_return(false)
          end

          it 'includes this file' do
            sources = described_class.new([path], configuration: configuration, options: options).sources
            expect(sources).to include(path)
          end
        end
      end

      context 'when the path is a file name in an excluded directory' do
        let(:path) { SAMPLES_PATH.join('source_with_exclude_paths', 'ignore_me', 'uncommunicative_method_name.rb') }

        context 'when options.force_exclusion? is true' do
          before do
            allow(options).to receive(:force_exclusion?).and_return(true)
          end

          it 'excludes this file' do
            sources = described_class.new([path], configuration: configuration, options: options).sources
            expect(sources).not_to include(path)
          end
        end

        context 'when options.force_exclusion? is false' do
          before do
            allow(options).to receive(:force_exclusion?).and_return(false)
          end

          it 'includes this file' do
            sources = described_class.new([path], configuration: configuration, options: options).sources
            expect(sources).to include(path)
          end
        end
      end

      context 'when path is a directory' do
        let(:path) { SAMPLES_PATH.join('source_with_exclude_paths') }

        let(:expected_paths) do
          [path.join('nested/uncommunicative_parameter_name.rb')]
        end

        let(:paths_that_are_expected_to_be_ignored) do
          [
            path.join('ignore_me/uncommunicative_method_name.rb'),
            path.join('nested/ignore_me_as_well/irresponsible_module.rb')
          ]
        end

        it 'does not use excluded paths' do
          sources = described_class.new([path], configuration: configuration, options: options).sources
          expect(sources).not_to include(*paths_that_are_expected_to_be_ignored)
        end

        it 'scans directories that are not excluded' do
          sources = described_class.new([path], configuration: configuration).sources
          expect(sources).to eq expected_paths
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    context 'non-Ruby paths' do
      let(:path) { SAMPLES_PATH.join('source_with_non_ruby_files') }
      let(:expected_sources) do
        [path.join('uncommunicative_parameter_name.rb')]
      end
      let(:paths_that_are_expected_to_be_ignored) do
        [
          path.join('gibberish'),
          path.join('python_source.py')
        ]
      end

      it 'uses Ruby source paths' do
        sources = described_class.new([path]).sources

        expect(sources).to include(*expected_sources)
      end

      it 'does not use non-Ruby source paths' do
        sources = described_class.new([path]).sources

        expect(sources).not_to include(*paths_that_are_expected_to_be_ignored)
      end
    end

    context 'passing "." or "./" as argument' do
      let(:expected_sources) do
        [Pathname.new('spec/spec_helper.rb'), Pathname.new('lib/reek.rb')]
      end

      it 'expands it correctly' do
        sources_for_dot = described_class.new([Pathname.new('.')]).sources

        expect(sources_for_dot).to include(*expected_sources)
      end

      it 'ignores the trailing slash' do
        sources_for_dot       = described_class.new([Pathname.new('.')]).sources
        sources_for_dot_slash = described_class.new([Pathname.new('./')]).sources

        expect(sources_for_dot).to eq(sources_for_dot_slash)
      end
    end
  end
end
