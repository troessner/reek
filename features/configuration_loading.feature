Feature: Offer different ways how to load configuration

  Reek can be configured in two ways:
  - Using the cli "-c" switch to pass a configuration file on the command line.
  - Having a Reek configuration file that is automatically found. Reek will
    look for a file ending in .reek.yml in the following places, in order:
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
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

  Scenario: Configuration via CLI
    Given the smelly file 'smelly.rb'
    And a configuration file 'full_mask.reek'
    When I run reek -c full_mask.reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Configuration file in working directory
    Given the smelly file 'smelly.rb'
    And a file named ".reek.yml" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          enabled: false
        UncommunicativeVariableName:
          enabled: false
      """
    When I run reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Do not use the default config file when we explicitly specify one configuration file
    Given the smelly file 'smelly.rb'
    And a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          enabled: false
      """
    And a file named ".reek.yml" with:
      """
      ---
      UncommunicativeVariableName:
        enabled: false
      """
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 1 warning:
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

  Scenario: Prefer the default config file over other configuration files
    Given the smelly file 'smelly.rb'
    And a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          enabled: false
      """
    And a file named ".reek.yml" with:
      """
      ---
      detectors:
        UncommunicativeVariableName:
          enabled: false
      """
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 1 warning:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
      """
