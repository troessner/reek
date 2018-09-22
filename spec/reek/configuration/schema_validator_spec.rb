require_relative '../../spec_helper'
require_lib 'reek/configuration/schema_validator'
require_lib 'reek/errors/config_file_error'

RSpec.describe Reek::Configuration::SchemaValidator do
  describe 'validate' do
    subject(:validator) { described_class.new configuration }

    context 'when configuration is valid' do
      let(:configuration) do
        {
          Reek::DETECTORS_KEY => {
            'UncommunicativeVariableName' => { 'enabled' => false },
            'UncommunicativeMethodName'   => { 'enabled' => false }
          }
        }
      end

      it 'returns nil' do
        expect(validator.validate).to eq(nil)
      end
    end

    context 'when detector is invalid' do
      let(:configuration) do
        {
          Reek::DETECTORS_KEY => {
            'DoesNotExist' => { 'enabled' => false }
          }
        }
      end

      it 'raises an error' do
        message = %r{\[/detectors/DoesNotExist\] key 'DoesNotExist:' is undefined}
        expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
      end
    end

    context 'when `enabled` has a non-boolean value' do
      let(:configuration) do
        {
          Reek::DETECTORS_KEY => {
            'FeatureEnvy' => { 'enabled' => 'foo' }
          }
        }
      end

      it 'raises an error' do
        message = %r{\[/detectors/FeatureEnvy/enabled\] 'foo': not a boolean}
        expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
      end
    end

    context 'when detector has an unknown option' do
      let(:configuration) do
        {
          Reek::DETECTORS_KEY => {
            'DataClump' => { 'does_not_exist' => 42 }
          }
        }
      end

      it 'raises an error' do
        message = %r{\[/detectors/DataClump/does_not_exist\] key 'does_not_exist:' is undefined}
        expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
      end
    end

    context 'when `exclude`, `reject` and `accept`' do
      %w(exclude reject accept).each do |attribute|
        context 'when a scalar' do
          let(:configuration) do
            {
              Reek::DETECTORS_KEY => {
                'UncommunicativeMethodName' => { attribute => 42 }
              }
            }
          end

          it 'raises an error' do
            message = %r{\[/detectors/UncommunicativeMethodName/#{attribute}\] '42': not a sequence}
            expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
          end
        end

        context 'when types are mixed' do
          let(:configuration) do
            {
              Reek::DETECTORS_KEY => {
                'UncommunicativeMethodName' => { attribute => [42, 'foo'] }
              }
            }
          end

          it 'raises an error' do
            message = %r{\[/detectors/UncommunicativeMethodName/#{attribute}/0\] '42': not a string}
            expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
          end
        end
      end
    end

    context 'when `exclude_paths` is a scalar' do
      let(:configuration) do
        {
          Reek::EXCLUDE_PATHS_KEY => 42
        }
      end

      it 'raises an error' do
        message = %r{\[/exclude_paths\] '42': not a sequence}
        expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
      end
    end

    context 'when `exclude_paths` mixes types' do
      let(:configuration) do
        {
          Reek::EXCLUDE_PATHS_KEY => [42, 'foo']
        }
      end

      it 'raises an error' do
        message = %r{\[/exclude_paths/0\] '42': not a string}
        expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
      end
    end

    context 'with directory directives' do
      context 'when bad detector' do
        let(:configuration) do
          {
            Reek::DIRECTORIES_KEY => {
              'web_app/app/helpers' => {
                'Bar' => { 'enabled' => false }
              }
            }
          }
        end

        it 'raises an error' do
          message = %r{\[/directories/web_app/app/helpers/Bar\] key 'Bar:' is undefined}
          expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
        end
      end

      context 'when unknown attribute' do
        let(:configuration) do
          {
            Reek::DIRECTORIES_KEY => {
              'web_app/app/controllers' => {
                'NestedIterators' => { 'foo' => false }
              }
            }
          }
        end

        it 'raises an error' do
          message = %r{\[/directories/web_app/app/controllers/NestedIterators/foo\] key 'foo:' is undefined}
          expect { validator.validate }.to raise_error(Reek::Errors::ConfigFileError, message)
        end
      end
    end
  end
end
