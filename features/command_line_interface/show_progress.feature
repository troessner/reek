Feature: Show progress
  In order to see the progress of the examiners
  As a developer
  I want to be able to selectively activate progress reporting

  # Note that --progress is the default on TTYs, but needs to be explicitely
  # enabled here because output in the cucumber scenarios does not go to a TTY.
  Scenario: shows progress output on mixed files by default
    Given a directory called 'mixed_files' containing some clean and smelly files
    When I run reek --progress mixed_files
    Then the exit status indicates smells
    And it reports:
      """
      Inspecting 2 file(s):
      .S

      mixed_files/dirty.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      2 total warnings
      """

  Scenario: --no-progress disables progress output
    Given a directory called 'mixed_files' containing some clean and smelly files
    When I run reek --no-progress mixed_files
    Then the exit status indicates smells
    And it reports:
      """
      mixed_files/dirty.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      2 total warnings
      """
