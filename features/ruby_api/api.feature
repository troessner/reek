@masking
Feature: The Reek API maintains backwards compatibility
  In order to use Reek witthout fuss
  As a developer
  I want to mave a stable API

  Scenario: the demo example reports as expected
    When I run reek spec/samples/demo
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/demo/demo.rb -- 6 warnings:
        Dirty has no descriptive comment (IrresponsibleModule)
        Dirty#awful has 4 parameters (LongParameterList)
        Dirty#awful has boolean parameter 'log' (ControlCouple)
        Dirty#awful has the parameter name 'x' (UncommunicativeName)
        Dirty#awful has the parameter name 'y' (UncommunicativeName)
        Dirty#awful has the variable name 'w' (UncommunicativeName)

      """
