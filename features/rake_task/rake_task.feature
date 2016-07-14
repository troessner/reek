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
      smelly.rb -- 4 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [2]:InstanceVariableAssumption: Smelly assumes too much for instance variable @foo [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

  Scenario: source_files using a FileList instead of a String
    Given a smelly file called 'smelly.rb'
    When I run rake reek with:
      """
      Reek::Rake::Task.new do |t|
        t.source_files = FileList['smelly.*']
        t.reek_opts = '--no-color'
      end
      """
    Then the exit status indicates an error
    And it reports:
      """
      smelly.rb -- 4 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [2]:InstanceVariableAssumption: Smelly assumes too much for instance variable @foo [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
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
      smelly.rb -- 4 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [2]:InstanceVariableAssumption: Smelly assumes too much for instance variable @foo [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
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
      smelly.rb -- 4 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [2]:InstanceVariableAssumption: Smelly assumes too much for instance variable @foo [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
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
