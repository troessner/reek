Feature: Reports total number of code smells
  In order to monitor the total number of smells
  Reek outputs the total number of smells among all files inspected.

  Scenario: Does not output total number of smells when inspecting single file
    Given a smelly file called 'smelly.rb'
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
      """

  Scenario: Output total number of smells when inspecting multiple files
    Given a directory called 'smelly' containing two smelly files
    When I run reek smelly
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      smelly/dirty_two.rb -- 3 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
      5 total warnings
      """

  Scenario: Output total number of smells even if total equals 0
    Given a directory called 'clean_files' containing some clean files
    When I run reek clean_files
    Then it succeeds
    And it reports:
      """
      0 total warnings
      """
