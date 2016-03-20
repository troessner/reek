Feature: Mix `accept` and `reject` configuration settings
  In order to have a more fine-grained control over what Reek reports
  As a user
  I want to be able to mix the `accept` and `reject` setting

  Scenario: UncommunicativeMethodName
    Given a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        accept:
          - !ruby/regexp /x/
          - meth1
        reject:
          - !ruby/regexp /helper/
          - foobar
      """
    And a file named "smelly.rb" with:
      """
      def x; end # Should not be reported
      def meth1; end # Should not be reported
      def foobar; end # Should be reported
      def awesome_helper; end # Should be reported
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 2 warnings:
      [4]:UncommunicativeMethodName: awesome_helper has the name 'awesome_helper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      [3]:UncommunicativeMethodName: foobar has the name 'foobar' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
    """

  Scenario: UncommunicativeModuleName
    Given a file named "config.reek" with:
      """
      ---
      IrresponsibleModule:
        enabled: false
      UncommunicativeModuleName:
        accept:
          - !ruby/regexp /lassy/
          - M
        reject:
          - !ruby/regexp /Helper/
      """
    And a file named "smelly.rb" with:
      """
      class Classy1; end # Should not be reported
      class M; end # Should not be reported
      class BaseHelper; end # Should be reported
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 1 warning:
      [3]:UncommunicativeModuleName: BaseHelper has the name 'BaseHelper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Module-Name.md]
    """

  Scenario: UncommunicativeParameterName
    Given a file named "config.reek" with:
      """
      ---
      UncommunicativeParameterName:
        accept:
          - !ruby/regexp /x/
          - arg1
        reject:
          - !ruby/regexp /foobar/
      """
    And a file named "smelly.rb" with:
      """
      def omg(x); x; end # Should not be reported
      def omg(arg1); arg1; end # Should not be reported
      def omg(foobar); foobar; end # Should be reported
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 1 warning:
      [3]:UncommunicativeParameterName: omg has the parameter name 'foobar' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
    """
