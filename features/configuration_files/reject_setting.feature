Feature: `reject` configuration setting
  In order to have a more fine-grained control over what Reek reports
  As a user
  I want to be able to reject specific patterns and names to include them into reporting

  Scenario: reject names
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          reject:
            - awesome_helper
            - little_helper
        UncommunicativeParameterName:
          reject:
            - solid_argument
            - nifty_argument
        UncommunicativeModuleName:
          reject:
            - Dummy
        UncommunicativeVariableName:
          reject:
            - fine_name
      """
    And a file named "smelly.rb" with:
      """
      # Should report UncommunicativeModuleName
      class Dummy
        # Should report UncommunicativeMethodName and UncommunicativeParameterName
        def awesome_helper(solid_argument); solid_argument; end
        # Should report UncommunicativeMethodName and UncommunicativeParameterName
        def little_helper(nifty_argument); nifty_argument; end
        # Should not report UncommunicativeMethodName and UncommunicativeParameterName
        def meth(argument); argument; end
        fine_name = 2 # Should report UncommunicativeMethodName
        other_name = 2 # Should not report UncommunicativeMethodName
      end
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 6 warnings:
      [4]:UncommunicativeMethodName: Dummy#awesome_helper has the name 'awesome_helper'
      [6]:UncommunicativeMethodName: Dummy#little_helper has the name 'little_helper'
      [2]:UncommunicativeModuleName: Dummy has the name 'Dummy'
      [4]:UncommunicativeParameterName: Dummy#awesome_helper has the parameter name 'solid_argument'
      [6]:UncommunicativeParameterName: Dummy#little_helper has the parameter name 'nifty_argument'
      [9]:UncommunicativeVariableName: Dummy has the variable name 'fine_name'
    """

  Scenario: Reject regexes
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          accept:
            - /oobar/
        UncommunicativeParameterName:
          accept:
            - /ola/
        UncommunicativeModuleName:
          accept:
            - /lassy/
        UncommunicativeVariableName:
          reject:
            - /^fine_name/
      """
    And a file named "smelly.rb" with:
      """
      # Should not report UncommunicativeModuleName
      class Classy1
        # Should not report UncommunicativeMethodName and UncommunicativeParameterName
        def foobar1(hola1); hola1; end
        # Should report UncommunicativeMethodName and UncommunicativeParameterName
        def m2(a2); a2; end
        fine_name = 2 # Should report UncommunicativeMethodName
        my_fine_name = 2 # Should not report UncommunicativeMethodName
      end
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 3 warnings:
      [6]:UncommunicativeMethodName: Classy1#m2 has the name 'm2'
      [6]:UncommunicativeParameterName: Classy1#m2 has the parameter name 'a2'
      [7]:UncommunicativeVariableName: Classy1 has the variable name 'fine_name'
    """
