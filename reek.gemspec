# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{reek}
  s.version = "0.3.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Rutherford"]
  s.date = %q{2009-04-03}
  s.default_executable = %q{reek}
  s.description = %q{Code smell detector for Ruby}
  s.email = ["kevin@rutherford-software.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["History.txt", "README.txt"]
  s.files = ["History.txt", "README.txt", "Rakefile", "bin/reek", "config/defaults.reek", "lib/reek.rb", "lib/reek/block_context.rb", "lib/reek/class_context.rb", "lib/reek/code_context.rb", "lib/reek/code_parser.rb", "lib/reek/exceptions.reek", "lib/reek/if_context.rb", "lib/reek/method_context.rb", "lib/reek/module_context.rb", "lib/reek/name.rb", "lib/reek/object_refs.rb", "lib/reek/options.rb", "lib/reek/rake_task.rb", "lib/reek/report.rb", "lib/reek/sexp_formatter.rb", "lib/reek/singleton_method_context.rb", "lib/reek/smell_warning.rb", "lib/reek/smells/control_couple.rb", "lib/reek/smells/duplication.rb", "lib/reek/smells/feature_envy.rb", "lib/reek/smells/large_class.rb", "lib/reek/smells/long_method.rb", "lib/reek/smells/long_parameter_list.rb", "lib/reek/smells/long_yield_list.rb", "lib/reek/smells/nested_iterators.rb", "lib/reek/smells/smell_detector.rb", "lib/reek/smells/smells.rb", "lib/reek/smells/uncommunicative_name.rb", "lib/reek/smells/utility_function.rb", "lib/reek/source.rb", "lib/reek/spec.rb", "lib/reek/stop_context.rb", "lib/reek/yield_call_context.rb", "reek.gemspec", "spec/integration/reek_source_spec.rb", "spec/integration/script_spec.rb", "spec/reek/class_context_spec.rb", "spec/reek/code_context_spec.rb", "spec/reek/code_parser_spec.rb", "spec/reek/config_spec.rb", "spec/reek/if_context_spec.rb", "spec/reek/method_context_spec.rb", "spec/reek/module_context_spec.rb", "spec/reek/object_refs_spec.rb", "spec/reek/options_spec.rb", "spec/reek/report_spec.rb", "spec/reek/sexp_formatter_spec.rb", "spec/reek/singleton_method_context_spec.rb", "spec/reek/smells/control_couple_spec.rb", "spec/reek/smells/duplication_spec.rb", "spec/reek/smells/feature_envy_spec.rb", "spec/reek/smells/large_class_spec.rb", "spec/reek/smells/long_method_spec.rb", "spec/reek/smells/long_parameter_list_spec.rb", "spec/reek/smells/nested_iterators_spec.rb", "spec/reek/smells/smell_spec.rb", "spec/reek/smells/uncommunicative_name_spec.rb", "spec/reek/smells/utility_function_spec.rb", "spec/samples/inline.rb", "spec/samples/inline_spec.rb", "spec/samples/optparse.rb", "spec/samples/optparse_spec.rb", "spec/samples/redcloth.rb", "spec/samples/redcloth_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/reek.rake", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://wiki.github.com/kevinrutherford/reek}
  s.post_install_message = %q{
For more information on reek, see http://wiki.github.com/kevinrutherford/reek
}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{reek}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Code smell detector for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ParseTree>, ["~> 3.0"])
      s.add_runtime_dependency(%q<sexp_processor>, ["~> 3.0"])
    else
      s.add_dependency(%q<ParseTree>, ["~> 3.0"])
      s.add_dependency(%q<sexp_processor>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<ParseTree>, ["~> 3.0"])
    s.add_dependency(%q<sexp_processor>, ["~> 3.0"])
  end
end
