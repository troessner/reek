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
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts(@foo.bar) 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

  Scenario: Output total number of smells when inspecting multiple files
    Given a directory called 'smelly' containing two smelly files
    When I run reek smelly
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      smelly/dirty_two.rb -- 3 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [3]:UncommunicativeMethodName: Dirty#b has the name 'b' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
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
