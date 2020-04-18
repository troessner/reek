require 'pathname'
require 'timeout'
require 'rspec-benchmark'
require_relative '../lib/reek'
require_relative '../lib/reek/spec'
require_relative '../lib/reek/ast/ast_node_class_map'
require_relative '../lib/reek/configuration/app_configuration'

require_relative '../samples/paths'

begin
  Reek::CLI::Silencer.without_warnings { require 'pry-byebug' }
rescue LoadError # rubocop:disable Lint/SuppressedException
end

# Simple helpers for our specs.
module Helpers
  def test_configuration_for(config)
    case config
    when Pathname
      configuration = Reek::Configuration::AppConfiguration.from_path(config)
    when Hash
      configuration = Reek::Configuration::AppConfiguration.from_hash config
    else
      raise "Unknown config given in `test_configuration_for`: #{config.inspect}"
    end
    configuration
  end

  # @param code [String] The given code.
  #
  # @return syntax_tree [Reek::AST::Node]
  def syntax_tree(code)
    Reek::Source::SourceCode.from(code).syntax_tree
  end

  # @param code [String] The given code.
  #
  # @return syntax_tree [Reek::Context::CodeContext]
  def code_context(code)
    Reek::Context::CodeContext.new(nil, syntax_tree(code))
  end

  # @param code [String] The given code.
  #
  # @return syntax_tree [Reek::Context::MethodContext]
  def method_context(code)
    Reek::Context::MethodContext.new(nil, syntax_tree(code))
  end

  # Helper methods to generate a configuration for smell types that support
  # `accept` and `reject` settings.
  %w(accept reject).each do |switch|
    define_method("#{switch}_configuration_for") do |smell_type, pattern:|
      hash = {
        smell_type => {
          switch => pattern
        }
      }
      Reek::Configuration::AppConfiguration.from_hash(hash)
    end
  end

  # :reek:UncommunicativeMethodName
  def sexp(type, *children)
    @klass_map ||= Reek::AST::ASTNodeClassMap.new
    @klass_map.klass_for(type).new(type, children)
  end

  def build_smell_warning(smell_type: 'FeatureEnvy',
                          context: 'self',
                          lines: [42],
                          message: 'smell warning message',
                          source: 'dummy_file',
                          parameters: {})
    Reek::SmellWarning.new(smell_type,
                           context: context,
                           lines: lines,
                           message: message,
                           source: source,
                           parameters: parameters)
  end

  def build_code_comment(comment: '', line: 1, source: 'string')
    Reek::CodeComment.new(comment: comment, line: line, source: source)
  end
end

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.include Helpers
  config.include RSpec::Benchmark::Matchers
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.disable_monkey_patching!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end
end

RSpec::Matchers.define_negated_matcher :not_reek_of, :reek_of

private

def require_lib(path)
  require_relative "../lib/#{path}"
end
