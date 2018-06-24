Feature: `accept` configuration setting
  In order to have a more fine-grained control over what Reek reports
  As a user
  I want to be able to accept specific patterns and names to exclude them from reporting

  Scenario: Accept names
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          accept:
            - m1
            - m2
        UncommunicativeParameterName:
          accept:
            - a1
            - a2
        UncommunicativeModuleName:
          accept:
            - C1
        UncommunicativeVariableName:
          accept:
            - var1
      """
    And a file named "smelly.rb" with:
      """
      # Should not report UncommunicativeModuleName
      class C1
        # Should not report UncommunicativeMethodName and UncommunicativeParameterName
        def m1(a1); a1; end
        # Should not report UncommunicativeMethodName and UncommunicativeParameterName
        def m2(a2); a2; end
        # Should report UncommunicativeMethodName and UncommunicativeParameterName
        def m3(a3); a3; end
        var1 = 2 #  Should not report UncommunicativeVariableName
        myvar1 = 2 # Should not report UncommunicativeVariableName
        var2 = 2 #  Should report UncommunicativeVariableName
      end
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 3 warnings:
      [8]:UncommunicativeMethodName: C1#m3 has the name 'm3'
      [8]:UncommunicativeParameterName: C1#m3 has the parameter name 'a3'
      [11]:UncommunicativeVariableName: C1 has the variable name 'var2'
    """

  Scenario: Accept regexes
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
          accept:
            - /^var1/
      """
    And a file named "smelly.rb" with:
      """
      # Should not report UncommunicativeModuleName
      class Classy1
        # Should not report UncommunicativeMethodName and UncommunicativeParameterName
        def foobar1(hola1); hola1; end
        # Should report UncommunicativeMethodName and UncommunicativeParameterName
        def m2(a2); a2; end
        var1 = 2 #  Should not report UncommunicativeVariableName
        myvar1 = 2 # Should report UncommunicativeVariableName
      end
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 3 warnings:
      [6]:UncommunicativeMethodName: Classy1#m2 has the name 'm2'
      [6]:UncommunicativeParameterName: Classy1#m2 has the parameter name 'a2'
      [8]:UncommunicativeVariableName: Classy1 has the variable name 'myvar1'
    """
