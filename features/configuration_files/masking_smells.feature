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
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

  Scenario: provide extra masking inline in comments
    Given a smelly file with inline masking called 'inline.rb'
    And a masking configuration file called 'config.reek'
    When I run reek -c config.reek inline.rb
    Then the exit status indicates smells
    And it reports:
      """
      inline.rb -- 2 warnings:
        [5]:UncommunicativeVariableName: Dirty has the variable name '@s' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
        [5]:UncommunicativeVariableName: Dirty#a has the variable name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: Disable UtilityFunction for non-public methods
    Given a smelly file called 'smelly.rb' with private, protected and public UtilityFunction methods
    And a configuration file disabling UtilityFunction for non-public methods called 'config.reek'
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 1 warning:
        [3]:UtilityFunction: Klass#public_method doesn't depend on instance state (maybe move it to another class?) [https://github.com/troessner/reek/blob/master/docs/Utility-Function.md]
      """
    But it does not report private or protected methods
