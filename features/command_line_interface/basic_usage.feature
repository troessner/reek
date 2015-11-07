Feature: The Reek CLI maintains backwards compatibility
  In order to use Reek without fuss
  As a developer
  I want to have a stable basic command line interface

  Scenario: the demo example reports as expected
    Given the smelly file 'demo.rb' from the example in the README
    When I run reek demo.rb
    Then the exit status indicates smells
    And it reports:
      """
      demo.rb -- 8 warnings:
        [3]:BooleanParameter: Dirty#awful has boolean parameter 'log'
        [1]:IrresponsibleModule: Dirty has no descriptive comment
        [3]:LongParameterList: Dirty#awful has 4 parameters
        [3]:UncommunicativeParameterName: Dirty#awful has the parameter name 'x'
        [5]:UncommunicativeVariableName: Dirty#awful has the variable name 'w'
        [3]:UnusedParameters: Dirty#awful has unused parameter 'log'
        [3]:UnusedParameters: Dirty#awful has unused parameter 'offset'
        [3]:UnusedParameters: Dirty#awful has unused parameter 'y'
      """
