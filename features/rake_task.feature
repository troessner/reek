@rake
Feature: Reek can be driven through its RakeTask
  Reek provides an easy way to integrate its use into Rakefiles,
  via the RakeTask class. These scenarios test its various options.

  Scenario: source_files points at the desired files
    When I run rake reek with:
      """
      Reek::RakeTask.new do |t|
        t.source_files = 'spec/samples/masked/dirty.rb'
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 3 warnings (+3 masked):
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a/block/block is nested (Nested Iterators)
      """

  Scenario: name changes the task name
    When I run rake silky with:
      """
      Reek::RakeTask.new('silky') do |t|
        t.source_files = 'spec/samples/masked/dirty.rb'
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 3 warnings (+3 masked):
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a/block/block is nested (Nested Iterators)
      """

  Scenario: verbose prints the reek command
    When I run rake reek with:
      """
      Reek::RakeTask.new do |t|
        t.source_files = 'spec/samples/masked/dirty.rb'
        t.verbose = true
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      /usr/bin/ruby1.8 -I"/home/kevin/Working/git/reek/lib" "/home/kevin/Working/git/reek/bin/reek"  "spec/samples/masked/dirty.rb"
      spec/samples/masked/dirty.rb -- 3 warnings (+3 masked):
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a/block/block is nested (Nested Iterators)
      """

  Scenario: fail_on_error can hide the error status
    When I run rake reek with:
      """
      Reek::RakeTask.new do |t|
        t.fail_on_error = false
        t.source_files = 'spec/samples/empty_config_file/dirty.rb'
      end
      """
    Then it succeeds
    And it reports:
      """
      spec/samples/empty_config_file/dirty.rb -- 6 warnings:
        Dirty has the variable name '@s' (Uncommunicative Name)
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a has the name 'a' (Uncommunicative Name)
        Dirty#a/block has the variable name 'x' (Uncommunicative Name)
        Dirty#a/block/block is nested (Nested Iterators)
      """
