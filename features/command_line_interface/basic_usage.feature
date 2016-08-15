Feature: The Reek CLI maintains backwards compatibility
  In order to use Reek without fuss
  As a developer
  I want to have a stable basic command line interface

  Scenario: the example from README reports as expected
    Given the smelly file 'smelly.rb'
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
    """
    smelly.rb -- 2 warnings:
      [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
    """
