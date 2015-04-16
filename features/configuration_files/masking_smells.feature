Feature: Masking smells using config files
  In order to keep my reports meaningful
  As a developer
  I want to mask some smells using config files

  Scenario: empty config file is ignored
    Given a smelly file called 'smelly.rb'
    And an empty configuration file called 'empty.reek'
    When I run reek -c empty.reek smelly.rb
    Then it reports the error 'Warning: Invalid configuration file "empty.reek" -- Empty file'
    And the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
      """

  Scenario: corrupt config file prevents normal output
    Given a smelly file called 'smelly.rb'
    And a corrupt configuration file called 'corrupt.reek'
    When I run reek -c corrupt.reek smelly.rb
    Then it reports the error 'Error: Invalid configuration file "corrupt.reek" -- Not a hash'
    And the exit status indicates an error
    And it reports nothing

  Scenario: missing source file is an error
    When I run reek not_here.rb
    Then it reports the error "Error: No such file - not_here.rb"

  Scenario: masking smells in the configuration file
    Given a smelly file called 'smelly.rb'
    And a masking configuration file called 'config.reek'
    When I run reek -c config.reek smelly.rb
    Then it succeeds
    And it reports nothing

  Scenario: allow masking some calls for duplication smell
    Given a smelly file called 'smelly.rb'
    And a configuration file masking some duplication smells called 'config.reek'
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
      """

  Scenario: provide extra masking inline in comments
    Given a smelly file with inline masking called 'inline.rb'
    And a masking configuration file called 'config.reek'
    When I run reek -c config.reek inline.rb
    Then the exit status indicates smells
    And it reports:
      """
      inline.rb -- 2 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      """
