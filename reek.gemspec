# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{reek}
  s.version = "1.1.3.14"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Rutherford"]
  s.date = %q{2009-08-20}
  s.default_executable = %q{reek}
  s.description = %q{Code smell detector for Ruby}
  s.email = ["kevin@rutherford-software.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "README.txt"]
  s.files = ["History.txt", "License.txt", "README.txt", "Rakefile", "bin/reek", "config/defaults.reek", "features/masking_smells.feature", "features/options.feature", "features/reports.feature", "features/samples.feature", "features/stdin.feature", "features/step_definitions/reek_steps.rb", "features/support/env.rb", "lib/reek.rb", "lib/reek/adapters/application.rb", "lib/reek/adapters/config_file.rb", "lib/reek/adapters/core_extras.rb", "lib/reek/adapters/object_source.rb", "lib/reek/adapters/rake_task.rb", "lib/reek/adapters/report.rb", "lib/reek/adapters/source.rb", "lib/reek/adapters/spec.rb", "lib/reek/block_context.rb", "lib/reek/class_context.rb", "lib/reek/code_context.rb", "lib/reek/code_parser.rb", "lib/reek/command_line.rb", "lib/reek/configuration.rb", "lib/reek/detector_stack.rb", "lib/reek/exceptions.reek", "lib/reek/if_context.rb", "lib/reek/method_context.rb", "lib/reek/module_context.rb", "lib/reek/name.rb", "lib/reek/object_refs.rb", "lib/reek/sexp_formatter.rb", "lib/reek/singleton_method_context.rb", "lib/reek/smell_warning.rb", "lib/reek/smells/control_couple.rb", "lib/reek/smells/duplication.rb", "lib/reek/smells/feature_envy.rb", "lib/reek/smells/large_class.rb", "lib/reek/smells/long_method.rb", "lib/reek/smells/long_parameter_list.rb", "lib/reek/smells/long_yield_list.rb", "lib/reek/smells/nested_iterators.rb", "lib/reek/smells/simulated_polymorphism.rb", "lib/reek/smells/smell_detector.rb", "lib/reek/smells/uncommunicative_name.rb", "lib/reek/smells/utility_function.rb", "lib/reek/sniffer.rb", "lib/reek/stop_context.rb", "lib/reek/yield_call_context.rb", "reek.gemspec", "spec/quality/reek_source_spec.rb", "spec/reek/adapters/report_spec.rb", "spec/reek/adapters/should_reek_of_spec.rb", "spec/reek/adapters/should_reek_only_of_spec.rb", "spec/reek/adapters/should_reek_spec.rb", "spec/reek/block_context_spec.rb", "spec/reek/class_context_spec.rb", "spec/reek/code_context_spec.rb", "spec/reek/code_parser_spec.rb", "spec/reek/config_spec.rb", "spec/reek/configuration_spec.rb", "spec/reek/if_context_spec.rb", "spec/reek/method_context_spec.rb", "spec/reek/module_context_spec.rb", "spec/reek/name_spec.rb", "spec/reek/object_refs_spec.rb", "spec/reek/object_source_spec.rb", "spec/reek/singleton_method_context_spec.rb", "spec/reek/smell_warning_spec.rb", "spec/reek/smells/control_couple_spec.rb", "spec/reek/smells/duplication_spec.rb", "spec/reek/smells/feature_envy_spec.rb", "spec/reek/smells/large_class_spec.rb", "spec/reek/smells/long_method_spec.rb", "spec/reek/smells/long_parameter_list_spec.rb", "spec/reek/smells/nested_iterators_spec.rb", "spec/reek/smells/simulated_polymorphism_spec.rb", "spec/reek/smells/smell_detector_spec.rb", "spec/reek/smells/uncommunicative_name_spec.rb", "spec/reek/smells/utility_function_spec.rb", "spec/reek/sniffer_spec.rb", "spec/samples/all_but_one_masked/clean_one.rb", "spec/samples/all_but_one_masked/dirty.rb", "spec/samples/all_but_one_masked/masked.reek", "spec/samples/clean_due_to_masking/clean_one.rb", "spec/samples/clean_due_to_masking/clean_three.rb", "spec/samples/clean_due_to_masking/clean_two.rb", "spec/samples/clean_due_to_masking/dirty_one.rb", "spec/samples/clean_due_to_masking/dirty_two.rb", "spec/samples/clean_due_to_masking/masked.reek", "spec/samples/corrupt_config_file/corrupt.reek", "spec/samples/corrupt_config_file/dirty.rb", "spec/samples/empty_config_file/dirty.rb", "spec/samples/empty_config_file/empty.reek", "spec/samples/exceptions.reek", "spec/samples/inline.rb", "spec/samples/masked/dirty.rb", "spec/samples/masked/masked.reek", "spec/samples/mixed_results/clean_one.rb", "spec/samples/mixed_results/clean_three.rb", "spec/samples/mixed_results/clean_two.rb", "spec/samples/mixed_results/dirty_one.rb", "spec/samples/mixed_results/dirty_two.rb", "spec/samples/not_quite_masked/dirty.rb", "spec/samples/not_quite_masked/masked.reek", "spec/samples/optparse.rb", "spec/samples/overrides/masked/dirty.rb", "spec/samples/overrides/masked/lower.reek", "spec/samples/overrides/upper.reek", "spec/samples/redcloth.rb", "spec/samples/three_clean_files/clean_one.rb", "spec/samples/three_clean_files/clean_three.rb", "spec/samples/three_clean_files/clean_two.rb", "spec/samples/two_smelly_files/dirty_one.rb", "spec/samples/two_smelly_files/dirty_two.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/reek.rake", "tasks/test.rake"]
  s.homepage = %q{http://wiki.github.com/kevinrutherford/reek}
  s.post_install_message = %q{
For more information on reek, see http://wiki.github.com/kevinrutherford/reek
}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{reek}
  s.rubygems_version = %q{1.3.5}
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
