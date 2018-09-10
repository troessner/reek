Feature: Auto-generate a todo file
  Write a Reek configuration as a kind of todo list that will prevent Reek
  from reporting smells on the current code. This can then be worked on later on.
  The main goal here would be to ease the Reek adoption by allowing developers to
  introduce Reek right away (e.g. for CI), exclude the "old" smells from getting reported
  and then fix them step by step.

  Scenario: Generate the default configuration file that disables all found smells
    Given the smelly file 'smelly.rb'
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """
    When I run reek --todo smelly.rb
    Then it succeeds
    And it reports:
      """

      '.reek.yml' generated! You can now use this as a starting point.
      """
    And a file named ".reek.yml" should exist
    And the file ".reek.yml" should contain:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          exclude:
          - Smelly#x
        UncommunicativeVariableName:
          exclude:
          - Smelly#x
      """
    When I run reek smelly.rb
    Then it succeeds

  Scenario: Reacts appropiately when there are no smells
    Given the clean file "clean.rb"
    When I run reek --todo clean.rb
    Then a file named ".reek.yml" should not exist
    And it reports:
      """

      No smells found - nothing to do, exiting.
      """

  Scenario: Don't overwrite existing .reek.yml files
    Given the smelly file 'smelly.rb'
    And a file named ".reek.yml" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          enabled: false
      """
    When I run reek smelly.rb
    Then it reports:
      """
      smelly.rb -- 1 warning:
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """
    When I run reek --todo smelly.rb
    Then it reports:
      """

      Existing '.reek.yml' detected - aborting.
      """
    When I run reek smelly.rb
    Then it reports:
      """
      smelly.rb -- 1 warning:
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

  Scenario: Ignore existing other configuration files that are passed explicitly
    Given the smelly file 'smelly.rb'
    And a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          enabled: false
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
      """
      smelly.rb -- 1 warning:
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """
    When I run reek -c config.reek --todo smelly.rb
    Then it succeeds
    And a file named ".reek.yml" should exist
    And the file ".reek.yml" should contain:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          exclude:
          - Smelly#x
        UncommunicativeVariableName:
          exclude:
          - Smelly#x
      """
    When I run reek smelly.rb
    Then it reports nothing
