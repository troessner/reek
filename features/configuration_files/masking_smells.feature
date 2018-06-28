Feature: Masking smells using config files
  In order to keep my reports meaningful
  As a developer
  I want to mask some smells using config files

  Scenario: corrupt config file prevents normal output
    Given the smelly file 'smelly.rb'
    And a configuration file 'corrupt.reek'
    When I run reek -c corrupt.reek smelly.rb
    And stderr reports:
    """
    Error: We found some problems with your configuration file: [/] 'Not a valid configuration file': not a mapping.
    """
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
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

  Scenario: provide extra masking inline in comments
    Given a file named "smelly_with_inline_mask.rb" with:
      """
      # Smelly class
      # disables :reek:UncommunicativeVariableName
      class Smelly
        # This will reek of UncommunicativeMethodName
        def x
          y = 10 # This will NOT reek of UncommunicativeVariableName
        end
      end
      """
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
      [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
      [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
    """

  Scenario: Disable UtilityFunction for non-public methods
    Given a file named "smelly_with_modifiers.rb" with:
      """
      # Smelly class for testing purposes
      class Klass
        def public_method(arg) arg.to_s; end
        protected
        def protected_method(arg) arg.to_s; end
        private
        def private_method(arg) arg.to_s; end
      end
      """
    And a file named "non_public_modifiers_mask.reek.yml" with:
      """
      ---
      detectors:
        UtilityFunction:
          public_methods_only: true
      """
    When I run reek -c non_public_modifiers_mask.reek.yml smelly_with_modifiers.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly_with_modifiers.rb -- 1 warning:
        [3]:UtilityFunction: Klass#public_method doesn't depend on instance state (maybe move it to another class?)
      """
    But it does not report private or protected methods
