@masking
Feature: The Reek API maintains backwards compatibility
  In order to use Reek without fuss
  As a developer
  I want to have a stable API

  Scenario: the demo example reports as expected
    When I run reek spec/samples/demo
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/demo/demo.rb -- 6 warnings:
        Dirty has no descriptive comment (IrresponsibleModule)
        Dirty#awful has 4 parameters (LongParameterList)
        Dirty#awful has boolean parameter 'log' (BooleanParameter)
        Dirty#awful has the parameter name 'x' (UncommunicativeParameterName)
        Dirty#awful has the parameter name 'y' (UncommunicativeParameterName)
        Dirty#awful has the variable name 'w' (UncommunicativeVariableName)

      """
