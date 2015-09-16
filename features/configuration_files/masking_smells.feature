Feature: Masking smells using config files
  In order to keep my reports meaningful
  As a developer
  I want to mask some smells using config files

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

  Scenario: Disable UtilityFunction for non-public methods
    Given a smelly file called 'smelly.rb' with private, protected and public UtilityFunction methods
    And a configuration file disabling UtilityFunction for non-public methods called 'config.reek'
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 1 warning:
        [3]:Klass#public_method doesn't depend on instance state (maybe move it to another class?) (UtilityFunction)
      """
    But it does not report private or protected methods
