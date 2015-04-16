Feature: Reek can be driven through its Task
  Reek provides an easy way to integrate its use into Rakefiles,
  via the Task class. These scenarios test its various options.

  Scenario: source_files points at the desired files
    Given a smelly file called 'smelly.rb'
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.source_files = 'smelly.rb'
        t.reek_opts = '--no-color'
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
      """

  Scenario: name changes the task name
    Given a smelly file called 'smelly.rb'
    When I run rake silky with:
      """
      Reek::Rake::Task.new('silky') do |t|
        t.source_files = 'smelly.rb'
        t.reek_opts = '--no-color'
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
      """

  Scenario: verbose prints the reek command
    Given a smelly file called 'smelly.rb'
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.source_files = 'smelly.rb'
        t.verbose = true
      end
      """
    Then the exit status indicates an error
    And stdout includes "Running 'reek' rake command"

  Scenario: fail_on_error can hide the error status
    Given a smelly file called 'smelly.rb'
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.fail_on_error = false
        t.source_files = 'smelly.rb'
        t.reek_opts = '--no-color'
      end
      """
    Then it reports no errors
    And it succeeds
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
      """

  Scenario: can be configured with config_file
    Given a smelly file called 'smelly.rb'
    And a masking configuration file called 'config.reek'
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.config_file  = 'config.reek'
        t.source_files = 'smelly.rb'
      end
      """
    Then it succeeds
    And it reports nothing
