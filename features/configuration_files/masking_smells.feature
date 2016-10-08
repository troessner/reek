Feature: Masking smells using config files
  In order to keep my reports meaningful
  As a developer
  I want to mask some smells using config files

  Scenario: corrupt config file prevents normal output
    Given the smelly file 'smelly.rb'
    And a configuration file 'corrupt.reek'
    When I run reek -c corrupt.reek smelly.rb
    Then it reports the error 'Error: Invalid configuration file "corrupt.reek" -- Not a hash'
    And the exit status indicates an error
    And it reports nothing

  Scenario: missing source file is an error
    When I run reek not_here.rb
    Then it reports the error "Error: No such file - not_here.rb"

  Scenario: masking smells in the configuration file
    Given the smelly file 'smelly.rb'
    And a configuration file 'full_mask.reek'
    When I run reek -c full_mask.reek smelly.rb
    Then it succeeds
    And it reports nothing

  Scenario: allow masking some calls for duplication smell
    Given the smelly file 'smelly.rb'
    And a configuration file 'partial_mask.reek'
    When I run reek -c partial_mask.reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 1 warning:
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: provide extra masking inline in comments
    Given the smelly file 'smelly_with_inline_mask.rb'
    And a configuration file 'partial_mask.reek'
    When I run reek -c partial_mask.reek smelly_with_inline_mask.rb
    Then it succeeds
    And it reports nothing

  Scenario: empty config file outputs normally
    Given the smelly file 'smelly.rb'
    And a configuration file 'empty.reek'
    When I run reek -c empty.reek smelly.rb
    Then the exit status indicates smells
    And it reports:
    """
    smelly.rb -- 2 warnings:
      [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
    """

  Scenario: Disable UtilityFunction for non-public methods
    Given the smelly file 'smelly_with_modifiers.rb'
    And a configuration file 'non_public_modifiers_mask.reek'
    When I run reek -c non_public_modifiers_mask.reek smelly_with_modifiers.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly_with_modifiers.rb -- 1 warning:
        [7]:UtilityFunction: Klass#public_method doesn't depend on instance state (maybe move it to another class?) [https://github.com/troessner/reek/blob/master/docs/Utility-Function.md]
      """
    But it does not report private or protected methods
