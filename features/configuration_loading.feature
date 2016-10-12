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
    Given the smelly file 'smelly.rb'
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: Configuration via CLI
    Given the smelly file 'smelly.rb'
    And a configuration file 'full_mask.reek'
    When I run reek -c full_mask.reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Configuration file in working directory
    Given the smelly file 'smelly.rb'
    And a configuration file 'full_mask.reek'
    When I run reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Two opposing configuration files and we stop after the first one
    Given the smelly file 'smelly.rb' in a subdirectory
    And a configuration file 'partial_mask.reek' in a subdirectory
    And a configuration file 'full_mask.reek'
    When I run "reek smelly.rb" in a subdirectory
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 1 warning:
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """
