Feature: Offer different ways how to load configuration

  There are 3 ways of passing reek a configuration file:
  - Using the cli "-c" switch
  - Having a file ending with .reek either in your current working directory or in a parent directory
  - Having a file ending with .reek in your HOME directory
  The order in which reek tries to find such a configuration file should exactly be like above:
  First reek should check if we have given it a configuration file explicitly via CLI.
  Then it should check the current working directory for a file and if it can't find one,
  it should traverse up the directories until it hits the root directory.
  And finally, it should check your HOME directory.

  Scenario: No configuration
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

  Scenario: Configuration via CLI
    Given a smelly file called 'smelly.rb'
    And a masking configuration file called 'config.reek'
    When I run reek -c config.reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Configuration file in working directory
    Given a smelly file called 'smelly.rb'
    And a masking configuration file called 'config.reek'
    When I run reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Configuration file in the parent directory of the working directory
    Given a smelly file called 'smelly.rb' in a subdirectory
    And a masking configuration file called 'config.reek'
    When I run "reek smelly.rb" in the subdirectory
    Then it reports no errors
    And it succeeds

  Scenario: Configuration file in the HOME directory
    Given a smelly file called 'smelly.rb'
    And a masking configuration file in the HOME directory
    When I run reek smelly.rb
    Then it reports no errors
    And it succeeds

  Scenario: Two opposing configuration files and we stop after the first one
    Given a smelly file called 'smelly.rb' in a subdirectory
    And an enabling configuration file in the subdirectory
    And a masking configuration file called 'config.reek'
    When I run "reek smelly.rb" in the subdirectory
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
      """
