Feature: Warn on multiple configuration files
  Reek is designed for one configuration file and for one configuration file only.
  We should make this clear to the user by warning him when we detect multiple
  configuration files and then exiting the program.

  Scenario: Warn on more than one configuration file
    Given the smelly file 'smelly.rb'
    And a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        enabled: false
      """
    And a file named ".todo.reek" with:
      """
      ---
      UtilityFunction:
        enabled: false
      """
    When I run reek smelly.rb
    Then it reports the error "Error: Found multiple configuration files '.todo.reek', 'config.reek'"
    And it reports the error "Reek supports only one configuration file. You have 2 options now:"
    And it reports the error "1) Remove all offending files"
    And it reports the error "2) Be specific about which one you want to load via the -c switch"
    And the exit status indicates an error

  Scenario: Do not warn on more than one when we explicitly specify one configuration file
    Given the smelly file 'smelly.rb'
    And a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        enabled: false
      """
    And a file named ".todo.reek" with:
      """
      ---
      UtilityFunction:
        enabled: false
      """
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates smells
    And it reports no errors

