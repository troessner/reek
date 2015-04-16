Feature: The Reek API maintains backwards compatibility
  In order to use Reek without fuss
  As a developer
  I want to have a stable API

  Scenario: the demo example reports as expected
    Given the smelly file 'demo.rb' from the example in the README
    When I run reek demo.rb
    Then the exit status indicates smells
    And it reports:
      """
      demo.rb -- 8 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [3]:Dirty#awful has 4 parameters (LongParameterList)
        [3]:Dirty#awful has boolean parameter 'log' (BooleanParameter)
        [3]:Dirty#awful has the parameter name 'x' (UncommunicativeParameterName)
        [5]:Dirty#awful has the variable name 'w' (UncommunicativeVariableName)
        [3]:Dirty#awful has unused parameter 'log' (UnusedParameters)
        [3]:Dirty#awful has unused parameter 'offset' (UnusedParameters)
        [3]:Dirty#awful has unused parameter 'y' (UnusedParameters)
      """
