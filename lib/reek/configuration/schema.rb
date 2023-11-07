# frozen_string_literal: true

require 'dry/schema'

module Reek
  module Configuration
    #
    # Configuration schema constants.
    #
    class Schema
      # Enable the :info extension so we can introspect
      # your keys and types
      Dry::Schema.load_extensions(:info)

      # rubocop:disable Metrics/BlockLength
      ALL_DETECTORS_SCHEMA = Dry::Schema.Params do
        optional(:Attribute).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:BooleanParameter).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:ClassVariable).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:ControlParameter).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:DataClump).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_copies).filled(:integer)
          optional(:min_clump_size).filled(:integer)
        end
        optional(:DuplicateMethodCall).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_calls).filled(:integer)
          optional(:allow_calls).array(:string)
        end
        optional(:FeatureEnvy).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:InstanceVariableAssumption).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:IrresponsibleModule).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:LongParameterList).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_params).filled(:integer)
          optional(:overrides).filled(:hash) do
            required(:initialize).filled(:hash) do
              required(:max_params).filled(:integer)
            end
          end
        end
        optional(:LongYieldList).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_params).filled(:integer)
        end
        optional(:ManualDispatch).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:MissingSafeMethod).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:ModuleInitialize).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:NestedIterators).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_allowed_nesting).filled(:integer)
          optional(:ignore_iterators) { array(:string) & filled? }
        end
        optional(:NilCheck).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:RepeatedConditional).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_ifs).filled(:integer)
        end
        optional(:SubclassedFromCoreClass).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:TooManyConstants).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_constants).filled(:integer)
        end
        optional(:TooManyInstanceVariables).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_instance_variables).filled(:integer)
        end
        optional(:TooManyMethods).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_methods).filled(:integer)
        end
        optional(:TooManyStatements).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:max_statements).filled(:integer)
        end
        optional(:UncommunicativeMethodName).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:reject).array(:string)
          optional(:accept).array(:string)
        end
        optional(:UncommunicativeModuleName).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:reject).array(:string)
          optional(:accept).array(:string)
        end
        optional(:UncommunicativeParameterName).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:reject).array(:string)
          optional(:accept).array(:string)
        end
        optional(:UncommunicativeVariableName).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:reject).array(:string)
          optional(:accept).array(:string)
        end
        optional(:UnusedParameters).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:UnusedPrivateMethod).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
        end
        optional(:UtilityFunction).filled(:hash) do
          optional(:enabled).filled(:bool)
          optional(:exclude).array(:string)
          optional(:public_methods_only).filled(:bool)
        end
      end
      # rubocop:enable Metrics/BlockLength

      # @quality :reek:TooManyStatements { max_statements: 7 }
      def self.schema(directories = [])
        Dry::Schema.Params do
          config.validate_keys = true

          optional(:detectors).filled(ALL_DETECTORS_SCHEMA)
          optional(:directories).filled(:hash) do
            directories.each { |dir| optional(dir.to_sym).filled(ALL_DETECTORS_SCHEMA) }
          end
          optional(:exclude_paths).array(:string)
        end
      end
    end
  end
end
