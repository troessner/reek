Feature: Reek can be driven through its Task
  Reek provides an easy way to integrate its use into Rakefiles,
  via the Task class. These scenarios test its various options.

  Scenario: source_files points at the desired files
    Given the smelly file 'smelly.rb'
    And a file "Rakefile" with:
      """
      require 'reek/rake/task'

      Reek::Rake::Task.new do |t|
        t.source_files = 'smelly.rb'
        t.reek_opts = '--no-color'
      end
      """
    When I run `rake reek`
    Then the exit status indicates an error
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: source_files using a FileList instead of a String
    Given the smelly file 'smelly.rb'
    And a file "Rakefile" with:
      """
      require 'reek/rake/task'

      Reek::Rake::Task.new do |t|
        t.source_files = FileList['smelly.*']
        t.reek_opts = '--no-color'
      end
      """
    When I run `rake reek`
    Then the exit status indicates an error
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: name changes the task name
    Given the smelly file 'smelly.rb'
    And a file "Rakefile" with:
      """
      require 'reek/rake/task'

      Reek::Rake::Task.new('silky') do |t|
        t.source_files = 'smelly.rb'
        t.reek_opts = '--no-color'
      end
      """
    When I run `rake silky`
    Then the exit status indicates an error
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: verbose prints the reek command
    Given the smelly file 'smelly.rb'
    And a file "Rakefile" with:
      """
      require 'reek/rake/task'

      Reek::Rake::Task.new do |t|
        t.source_files = 'smelly.rb'
        t.verbose = true
      end
      """
    When I run `rake reek`
    Then the exit status indicates an error
    And stdout includes "Running 'reek' rake command"

  Scenario: fail_on_error can hide the error status
    Given the smelly file 'smelly.rb'
    And a file "Rakefile" with:
      """
      require 'reek/rake/task'

      Reek::Rake::Task.new do |t|
        t.fail_on_error = false
        t.source_files = 'smelly.rb'
        t.reek_opts = '--no-color'
      end
      """
    When I run `rake reek`
    Then it reports no errors
    And it succeeds
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: can be configured with config_file
    Given the smelly file 'smelly.rb'
    And a configuration file 'full_mask.reek'
    And a file "Rakefile" with:
      """
      require 'reek/rake/task'

      Reek::Rake::Task.new do |t|
        t.config_file  = 'full_mask.reek'
        t.source_files = 'smelly.rb'
      end
      """
    When I run `rake reek`
    Then it succeeds
    And it reports nothing

  Scenario: REEK_SRC overrides the files to check
    Given the smelly file 'smelly.rb'
    And the clean file 'clean.rb'
    And a file "Rakefile" with:
      """
      require 'reek/rake/task'

      Reek::Rake::Task.new do |t|
        t.source_files = 'clean.rb'
        t.reek_opts = '--no-color'
      end
      """
    When I set the environment variable "REEK_SRC" to "smelly.rb"
    And I run `rake reek`
    Then the exit status indicates an error
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """
