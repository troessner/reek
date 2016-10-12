Feature: `reject` configuration setting
  In order to have a more fine-grained control over what Reek reports
  As a user
  I want to be able to reject specific patterns and names to include them into reporting

  Scenario: reject names as list and as single item
    Given a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        reject:
          - awesome_helper
          - little_helper
      UncommunicativeParameterName:
        reject:
          - solid_argument
          - nifty_argument
      UncommunicativeModuleName:
        reject: Dummy
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
      end
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 5 warnings:
      [4]:UncommunicativeMethodName: Dummy#awesome_helper has the name 'awesome_helper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [6]:UncommunicativeMethodName: Dummy#little_helper has the name 'little_helper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [2]:UncommunicativeModuleName: Dummy has the name 'Dummy' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Module-Name.md]
      [4]:UncommunicativeParameterName: Dummy#awesome_helper has the parameter name 'solid_argument' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
      [6]:UncommunicativeParameterName: Dummy#little_helper has the parameter name 'nifty_argument' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
    """

  Scenario: reject regexes as list and as single item
    Given a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        reject: !ruby/regexp /helper/
      UncommunicativeParameterName:
        reject:
          - !ruby/regexp /solid/
          - !ruby/regexp /nifty/
      UncommunicativeModuleName:
        reject: !ruby/regexp /ummy/
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
      end
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 5 warnings:
      [4]:UncommunicativeMethodName: Dummy#awesome_helper has the name 'awesome_helper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [6]:UncommunicativeMethodName: Dummy#little_helper has the name 'little_helper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [2]:UncommunicativeModuleName: Dummy has the name 'Dummy' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Module-Name.md]
      [4]:UncommunicativeParameterName: Dummy#awesome_helper has the parameter name 'solid_argument' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
      [6]:UncommunicativeParameterName: Dummy#little_helper has the parameter name 'nifty_argument' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
    """
