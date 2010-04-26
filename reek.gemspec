# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{reek}
  s.version = "1.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Rutherford"]
  s.date = %q{2010-04-26}
  s.default_executable = %q{reek}
  s.description = %q{Reek is a tool that examines Ruby classes, modules and methods
and reports any code smells it finds.
}
  s.email = ["kevin@rutherford-software.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["History.txt", "License.txt"]
  s.files = [".yardopts", "History.txt", "License.txt", "README.md", "Rakefile", "bin/reek", "config/defaults.reek", "features/api.feature", "features/masking_smells.feature", "features/options.feature", "features/rake_task.feature", "features/reports.feature", "features/samples.feature", "features/stdin.feature", "features/step_definitions/reek_steps.rb", "features/support/env.rb", "features/yaml.feature", "lib/reek.rb", "lib/reek/cli/application.rb", "lib/reek/cli/command_line.rb", "lib/reek/cli/help_command.rb", "lib/reek/cli/reek_command.rb", "lib/reek/cli/report.rb", "lib/reek/cli/version_command.rb", "lib/reek/cli/yaml_command.rb", "lib/reek/core/code_context.rb", "lib/reek/core/code_parser.rb", "lib/reek/core/method_context.rb", "lib/reek/core/module_context.rb", "lib/reek/core/object_refs.rb", "lib/reek/core/singleton_method_context.rb", "lib/reek/core/smell_configuration.rb", "lib/reek/core/sniffer.rb", "lib/reek/core/stop_context.rb", "lib/reek/core/warning_collector.rb", "lib/reek/examiner.rb", "lib/reek/rake/task.rb", "lib/reek/smell_warning.rb", "lib/reek/smells.rb", "lib/reek/smells/attribute.rb", "lib/reek/smells/boolean_parameter.rb", "lib/reek/smells/class_variable.rb", "lib/reek/smells/control_couple.rb", "lib/reek/smells/data_clump.rb", "lib/reek/smells/duplication.rb", "lib/reek/smells/feature_envy.rb", "lib/reek/smells/irresponsible_module.rb", "lib/reek/smells/large_class.rb", "lib/reek/smells/long_method.rb", "lib/reek/smells/long_parameter_list.rb", "lib/reek/smells/long_yield_list.rb", "lib/reek/smells/nested_iterators.rb", "lib/reek/smells/simulated_polymorphism.rb", "lib/reek/smells/smell_detector.rb", "lib/reek/smells/uncommunicative_method_name.rb", "lib/reek/smells/uncommunicative_module_name.rb", "lib/reek/smells/uncommunicative_parameter_name.rb", "lib/reek/smells/uncommunicative_variable_name.rb", "lib/reek/smells/utility_function.rb", "lib/reek/source.rb", "lib/reek/source/code_comment.rb", "lib/reek/source/config_file.rb", "lib/reek/source/core_extras.rb", "lib/reek/source/reference_collector.rb", "lib/reek/source/sexp_formatter.rb", "lib/reek/source/source_code.rb", "lib/reek/source/source_file.rb", "lib/reek/source/source_locator.rb", "lib/reek/source/tree_dresser.rb", "lib/reek/spec.rb", "lib/reek/spec/should_reek.rb", "lib/reek/spec/should_reek_of.rb", "lib/reek/spec/should_reek_only_of.rb", "reek.gemspec", "spec/matchers/smell_of_matcher.rb", "spec/reek/cli/help_command_spec.rb", "spec/reek/cli/reek_command_spec.rb", "spec/reek/cli/report_spec.rb", "spec/reek/cli/version_command_spec.rb", "spec/reek/cli/yaml_command_spec.rb", "spec/reek/core/code_context_spec.rb", "spec/reek/core/code_parser_spec.rb", "spec/reek/core/config_spec.rb", "spec/reek/core/method_context_spec.rb", "spec/reek/core/module_context_spec.rb", "spec/reek/core/object_refs_spec.rb", "spec/reek/core/singleton_method_context_spec.rb", "spec/reek/core/smell_configuration_spec.rb", "spec/reek/core/stop_context_spec.rb", "spec/reek/core/warning_collector_spec.rb", "spec/reek/examiner_spec.rb", "spec/reek/smell_warning_spec.rb", "spec/reek/smells/attribute_spec.rb", "spec/reek/smells/behaves_like_variable_detector.rb", "spec/reek/smells/boolean_parameter_spec.rb", "spec/reek/smells/class_variable_spec.rb", "spec/reek/smells/control_couple_spec.rb", "spec/reek/smells/data_clump_spec.rb", "spec/reek/smells/duplication_spec.rb", "spec/reek/smells/feature_envy_spec.rb", "spec/reek/smells/irresponsible_module_spec.rb", "spec/reek/smells/large_class_spec.rb", "spec/reek/smells/long_method_spec.rb", "spec/reek/smells/long_parameter_list_spec.rb", "spec/reek/smells/long_yield_list_spec.rb", "spec/reek/smells/nested_iterators_spec.rb", "spec/reek/smells/simulated_polymorphism_spec.rb", "spec/reek/smells/smell_detector_shared.rb", "spec/reek/smells/uncommunicative_method_name_spec.rb", "spec/reek/smells/uncommunicative_module_name_spec.rb", "spec/reek/smells/uncommunicative_parameter_name_spec.rb", "spec/reek/smells/uncommunicative_variable_name_spec.rb", "spec/reek/smells/utility_function_spec.rb", "spec/reek/source/code_comment_spec.rb", "spec/reek/source/object_source_spec.rb", "spec/reek/source/reference_collector_spec.rb", "spec/reek/source/source_code_spec.rb", "spec/reek/source/tree_dresser_spec.rb", "spec/reek/spec/should_reek_of_spec.rb", "spec/reek/spec/should_reek_only_of_spec.rb", "spec/reek/spec/should_reek_spec.rb", "spec/samples/all_but_one_masked/clean_one.rb", "spec/samples/all_but_one_masked/dirty.rb", "spec/samples/all_but_one_masked/masked.reek", "spec/samples/clean_due_to_masking/clean_one.rb", "spec/samples/clean_due_to_masking/clean_three.rb", "spec/samples/clean_due_to_masking/clean_two.rb", "spec/samples/clean_due_to_masking/dirty_one.rb", "spec/samples/clean_due_to_masking/dirty_two.rb", "spec/samples/clean_due_to_masking/masked.reek", "spec/samples/config/allow_duplication.reek", "spec/samples/config/deeper_nested_iterators.reek", "spec/samples/corrupt_config_file/corrupt.reek", "spec/samples/corrupt_config_file/dirty.rb", "spec/samples/demo/demo.rb", "spec/samples/empty_config_file/dirty.rb", "spec/samples/empty_config_file/empty.reek", "spec/samples/exceptions.reek", "spec/samples/inline_config/dirty.rb", "spec/samples/inline_config/masked.reek", "spec/samples/inline.rb", "spec/samples/mask_some/dirty.rb", "spec/samples/mask_some/some.reek", "spec/samples/masked/dirty.rb", "spec/samples/masked/masked.reek", "spec/samples/mixed_results/clean_one.rb", "spec/samples/mixed_results/clean_three.rb", "spec/samples/mixed_results/clean_two.rb", "spec/samples/mixed_results/dirty_one.rb", "spec/samples/mixed_results/dirty_two.rb", "spec/samples/not_quite_masked/dirty.rb", "spec/samples/not_quite_masked/masked.reek", "spec/samples/optparse.rb", "spec/samples/overrides/masked/dirty.rb", "spec/samples/overrides/masked/lower.reek", "spec/samples/overrides/upper.reek", "spec/samples/redcloth.rb", "spec/samples/three_clean_files/clean_one.rb", "spec/samples/three_clean_files/clean_three.rb", "spec/samples/three_clean_files/clean_two.rb", "spec/samples/two_smelly_files/dirty_one.rb", "spec/samples/two_smelly_files/dirty_two.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/reek.rake", "tasks/test.rake"]
  s.homepage = %q{http://wiki.github.com/kevinrutherford/reek}
  s.post_install_message = %q{
Thank you for downloading Reek. For info:
  - see the reek wiki http://wiki.github.com/kevinrutherford/reek
  - follow @rubyreek on twitter
}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{reek}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Code smell detector for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby_parser>, ["~> 2.0"])
      s.add_runtime_dependency(%q<ruby2ruby>, ["~> 1.2"])
      s.add_runtime_dependency(%q<sexp_processor>, ["~> 3.0"])
    else
      s.add_dependency(%q<ruby_parser>, ["~> 2.0"])
      s.add_dependency(%q<ruby2ruby>, ["~> 1.2"])
      s.add_dependency(%q<sexp_processor>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<ruby_parser>, ["~> 2.0"])
    s.add_dependency(%q<ruby2ruby>, ["~> 1.2"])
    s.add_dependency(%q<sexp_processor>, ["~> 3.0"])
  end
end
