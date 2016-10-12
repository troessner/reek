Feature: Smell selection
  In order to focus on particular code smells
  As a developer
  I want to be able to selectively activate smell detectors

  Scenario: --smell selects a smell to detect
    Given the smelly file 'smelly.rb'
    And a configuration file 'partial_mask.reek'
    When I run reek --no-line-numbers --smell UncommunicativeVariableName smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 1 warning:
        UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """
