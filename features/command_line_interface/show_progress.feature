Feature: Show progress
  In order to see the progress of the examiners
  As a developer
  I want to be able to selectively activate progress reporting

  Scenario: shows progress output on mixed files by default
    Given a directory called 'mixed_files' containing some clean and smelly files
    When I run reek mixed_files
    Then the exit status indicates smells
    And it reports:
      """
      Inspecting 2 file(s):
      .S

      mixed_files/dirty.rb -- 2 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      2 total warnings
      """

  Scenario: --no-progress disables progress output
    Given a directory called 'mixed_files' containing some clean and smelly files
    When I run reek --no-progress mixed_files
    Then the exit status indicates smells
    And it reports:
      """
      mixed_files/dirty.rb -- 2 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      2 total warnings
      """
