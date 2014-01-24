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
      spec/samples/demo/demo.rb -- 8 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [3]:Dirty#awful has 4 parameters (LongParameterList)
        [3]:Dirty#awful has boolean parameter 'log' (BooleanParameter)
        [5]:Dirty#awful has the variable name 'w' (UncommunicativeVariableName)
        [3]:Dirty#awful has unused parameter 'log' (UnusedParameters)
        [3]:Dirty#awful has unused parameter 'offset' (UnusedParameters)
        [3]:Dirty#awful has unused parameter 'x' (UnusedParameters)
        [3]:Dirty#awful has unused parameter 'y' (UnusedParameters)
      """
