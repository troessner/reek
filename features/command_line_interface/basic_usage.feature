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
        [3]:BooleanParameter: Dirty#awful has boolean parameter 'log' [https://github.com/troessner/reek/blob/master/docs/Boolean-Parameter.md]
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [3]:LongParameterList: Dirty#awful has 4 parameters [https://github.com/troessner/reek/blob/master/docs/Long-Parameter-List.md]
        [3]:UncommunicativeParameterName: Dirty#awful has the parameter name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
        [5]:UncommunicativeVariableName: Dirty#awful has the variable name 'w' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
        [3]:UnusedParameters: Dirty#awful has unused parameter 'log' [https://github.com/troessner/reek/blob/master/docs/Unused-Parameters.md]
        [3]:UnusedParameters: Dirty#awful has unused parameter 'offset' [https://github.com/troessner/reek/blob/master/docs/Unused-Parameters.md]
        [3]:UnusedParameters: Dirty#awful has unused parameter 'y' [https://github.com/troessner/reek/blob/master/docs/Unused-Parameters.md]
      """
