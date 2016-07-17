Feature: Show progress
  In order to see the progress of the examiners
  As a developer
  I want to be able to selectively activate progress reporting

  Scenario: --progress activates progress output on clean files
    Given a directory called 'clean_files' containing some clean files
    When I run reek -f progress clean_files
    Then it succeeds
    And it reports:
      """
      Inspecting 3 file(s):
      ...

      0 total warnings
      """
  Scenario: --progress activates progress output on smelly files
    Given a smelly file called 'smelly.rb'
    When I run reek -f progress smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      Inspecting 1 file(s):
      S

      smelly.rb -- 3 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """
