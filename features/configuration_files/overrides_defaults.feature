Feature: Overriding current rules by specifying new configuration values
  In order to customize Reek to suit my needs
  As a developer
  I want to be able to override the default configuration values

  Scenario: List of configuration values is overridden by a lower configuration file
    Given a file with smelly variable names called 'camel_case.rb'
    And a configuration file allowing camel case variables
    When I run reek camel_case.rb
    Then the exit status indicates smells
    And it reports:
      """
      camel_case.rb -- 1 warning:
        [9]:CamelCase#initialize has the variable name 'x1' (UncommunicativeVariableName)
      """
