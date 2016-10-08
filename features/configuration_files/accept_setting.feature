Feature: `accept` configuration setting
  In order to have a more fine-grained control over what Reek reports
  As a user
  I want to be able to accept specific patterns and names to exclude them from reporting

  Scenario: Accept names as list and as single item
    Given a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        accept:
          - m1
          - m2
      UncommunicativeParameterName:
        accept:
          - a1
          - a2
      UncommunicativeModuleName:
        accept: C1
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
      end
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 2 warnings:
      [8]:UncommunicativeMethodName: C1#m3 has the name 'm3' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [8]:UncommunicativeParameterName: C1#m3 has the parameter name 'a3' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
    """

  Scenario: Accept regexes as list and as single item
    Given a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        accept:
          - !ruby/regexp /oobar/
      UncommunicativeParameterName:
        accept:
          - !ruby/regexp /ola/
      UncommunicativeModuleName:
        accept: !ruby/regexp /lassy/
      """
    And a file named "smelly.rb" with:
      """
      # Should not report UncommunicativeModuleName
      class Classy1
        # Should not report UncommunicativeMethodName and UncommunicativeParameterName
        def foobar1(hola1); hola1; end
        # Should report UncommunicativeMethodName and UncommunicativeParameterName
        def m2(a2); a2; end
      end
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 2 warnings:
      [6]:UncommunicativeMethodName: Classy1#m2 has the name 'm2' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [6]:UncommunicativeParameterName: Classy1#m2 has the parameter name 'a2' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
    """
