Feature: Reports total number of code smells
  In order to monitor the total number of smells
  Reek outputs the total number of smells among all files inspected.

  Scenario: Does not output total number of smells when inspecting single file
    Given the smelly file 'smelly.rb'
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

  Scenario: Output total number of smells when inspecting multiple files
    Given a directory called 'smelly' containing two smelly files
    When I run reek smelly
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      smelly/dirty_two.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      4 total warnings
      """

  Scenario: Output total number of smells even if total equals 0
    Given a directory called 'clean' containing two clean files
    When I run reek clean
    Then it succeeds
    And it reports:
      """
      0 total warnings
      """
