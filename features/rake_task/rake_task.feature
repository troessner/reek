@rake
Feature: Reek can be driven through its Task
  Reek provides an easy way to integrate its use into Rakefiles,
  via the Task class. These scenarios test its various options.

  Scenario: source_files points at the desired files
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.source_files = 'spec/samples/masked/dirty.rb'
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 3 warnings:
        [4, 6]:Dirty#a calls @s.title twice (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
      """

  Scenario: name changes the task name
    When I run rake silky with:
      """
      Reek::Rake::Task.new('silky') do |t|
        t.source_files = 'spec/samples/masked/dirty.rb'
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 3 warnings:
        [4, 6]:Dirty#a calls @s.title twice (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
      """

  Scenario: verbose prints the reek command
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.source_files = 'spec/samples/masked/dirty.rb'
        t.verbose = true
      end
      """
    Then the exit status indicates an error
    And stdout includes /spec\/samples\/masked\/dirty\.rb/

  Scenario: fail_on_error can hide the error status
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.fail_on_error = false
        t.source_files = 'spec/samples/empty_config_file/dirty.rb'
      end
      """
    Then it succeeds
    And it reports:
      """
      spec/samples/empty_config_file/dirty.rb -- 6 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [4, 6]:Dirty#a calls @s.title twice (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
        [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      """

  Scenario: can be configured with config_files
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.config_files = 'spec/samples/config/**/*.reek'
        t.source_files = 'spec/samples/masked/dirty.rb'
      end
      """
    Then it succeeds
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 0 warnings
      """
