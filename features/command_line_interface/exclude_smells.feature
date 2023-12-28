Feature: Exclude smells
  In order to exclude specific code smells
  As a developer
  I want to be able to selectively exclude smell detectors

  Scenario: --exclude-smell selects smells to exclude
    Given the smelly file 'smelly.rb'
    When I run reek --no-line-numbers --exclude-smell UncommunicativeMethodName --exclude-smell UncommunicativeVariableName smelly.rb
    Then the exit status is 0
    And it reports:
      """
      """
