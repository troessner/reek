require_relative '../../spec_helper'
require_relative '../../../lib/reek/source/source_locator'

RSpec.describe Reek::Source::SourceLocator do
  describe '#sources' do
    context 'applied to hidden directories' do
      let(:path) { 'spec/samples/source_with_hidden_directories' }
      let(:expected_files) do
        ['spec/samples/source_with_hidden_directories/uncommunicative_parameter_name.rb']
      end
      let(:files_that_are_expected_to_be_ignored) do
        ['spec/samples/source_with_hidden_directories/.hidden/uncommunicative_method_name.rb']
      end

      it 'does not scan hidden directories' do
        sources = described_class.new([path]).sources

        expect(sources.map(&:path)).
          not_to include(*files_that_are_expected_to_be_ignored)

        expect(sources.map(&:path)).to eq expected_files
      end
    end

    context 'exclude paths' do
      let(:config) { 'spec/samples/configuration/with_excluded_paths.reek' }
      let(:path) { 'spec/samples/source_with_exclude_paths' }
      let(:files_that_are_expected_to_be_ignored) do
        [
          'spec/samples/source_with_exclude_paths/ignore_me/uncommunicative_method_name.rb',
          'spec/samples/source_with_exclude_paths/nested/ignore_me_as_well/irresponsible_module.rb'
        ]
      end

      it 'does not use excluded paths' do
        with_test_config(config) do
          sources = described_class.new([path]).sources

          expect(sources.map(&:path).sort).
            not_to include(*files_that_are_expected_to_be_ignored)

          expect(sources.map(&:path).sort).to eq [
            'spec/samples/source_with_exclude_paths/nested/uncommunicative_parameter_name.rb'
          ]
        end
      end
    end

    context 'non-ruby files' do
      let(:path) { 'spec/samples/source_with_non_ruby_files' }
      let(:expected_files) do
        ['spec/samples/source_with_non_ruby_files/uncommunicative_parameter_name.rb']
      end
      let(:files_that_are_expected_to_be_ignored) do
        [
          'spec/samples/source_with_non_ruby_files/gibberish',
          'spec/samples/source_with_non_ruby_files/python_source.py'
        ]
      end

      it 'does only use ruby source files' do
        sources = described_class.new([path]).sources

        expect(sources.map(&:path)).
          not_to include(*files_that_are_expected_to_be_ignored)

        expect(sources.map(&:path)).to eq expected_files
      end
    end

    context 'passing "." or "./" as argument' do
      let(:expected_files) do
        [
          'spec/spec_helper.rb',
          'lib/reek.rb'
        ]
      end

      it 'expands it correctly' do
        sources_for_dot       = described_class.new(['.']).sources
        sources_for_dot_slash = described_class.new(['./']).sources

        expect(sources_for_dot.map(&:path)).to include(*expected_files)
        expect(sources_for_dot.map(&:path)).to eq(sources_for_dot_slash.map(&:path))
      end
    end
  end
end
