Feature: Include other configuration files
  In order to give users more flexibility when it comes to configuration files
  we want to make it possible to include other configuration files into the main
  configuration file.

  Scenario: Include other configuration files
    Given a file named "smelly.rb" with:
      """
        class Smelly # IrresponsibleModule
          # UncommunicativeMethodName
          def x(y) # UncommunicativeParameterName and UnusedParameter
            z = 10 # UncommunicativeVariableName
          end
        end
      """
    And a file named ".reek.yml" with:
      """
      ---
      detectors:
        IrresponsibleModule:
          enabled: false
      include:
        - second_config.yml
        - third_config.yml
      """
    And a file named "second_config.yml" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          enabled: false
      """
    And a file named "third_config.yml" with:
      """
      ---
      detectors:
        UncommunicativeVariableName:
          enabled: false
      """

    When I run reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 2 warnings:
      [3]:UncommunicativeParameterName: Smelly#x has the parameter name 'y'
      [3]:UnusedParameters: Smelly#x has unused parameter 'y'
    """

  Scenario: Included file has additional include directives

  Scenario: Other configuration file overwrites configuration in the main configuration

  Scenario: Other configuration file does not exist

  Scenario: Other configuration file contains a syntax error
