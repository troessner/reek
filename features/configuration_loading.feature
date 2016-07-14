Feature: Offer different ways how to load configuration

  Reek can be configured in two ways:
  - Using the cli "-c" switch to pass a configuration file on the command line.
  - Having a Reek configuration file that is automatically found. Reek will
    look for a file ending in .reek in the following places, in order:
    - The current working directory
    - The working directory's ancestor directories, traversing all the way up
      to the root.
    - Your HOME directory
    Reek will check these in order and stop after the first file found.

  Scenario: Default configuration
    Given a smelly file called 'smelly.rb'
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 4 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [2]:InstanceVariableAssumption: Smelly assumes too much for instance variable @foo [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

  Scenario: Configuration via CLI
    Given a smelly file called 'smelly.rb'
    And a masking configuration file called 'config.reek'
    When I run reek -c config.reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Configuration file in working directory
    Given a smelly file called 'smelly.rb'
    And a masking configuration file called 'config.reek'
    When I run reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Two opposing configuration files and we stop after the first one
    Given a smelly file called 'smelly.rb' in a subdirectory
    And an enabling configuration file in the subdirectory
    And a masking configuration file called 'config.reek'
    When I run "reek smelly.rb" in the subdirectory
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 4 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [2]:InstanceVariableAssumption: Smelly assumes too much for instance variable @foo [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """
