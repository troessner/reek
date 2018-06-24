Feature: Mix `accept` and `reject` configuration settings
  In order to have a more fine-grained control over what Reek reports
  As a user
  I want to be able to mix the `accept` and `reject` setting

  Scenario: UncommunicativeMethodName
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeMethodName:
          accept:
            - x
            - meth1
          reject:
            - helper
            - foobar
      """
    And a file named "smelly.rb" with:
      """
      def x; end # Should not be reported
      def meth1; end # Should not be reported
      def foobar; end # Should be reported
      def awesome_helper; end # Should be reported
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 2 warnings:
      [4]:UncommunicativeMethodName: awesome_helper has the name 'awesome_helper'
      [3]:UncommunicativeMethodName: foobar has the name 'foobar'
    """

  Scenario: UncommunicativeModuleName
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        IrresponsibleModule:
          enabled: false
        UncommunicativeModuleName:
          accept:
            - lassy
            - M
          reject:
            - Helper
      """
    And a file named "smelly.rb" with:
      """
      class Classy1; end # Should not be reported
      class M; end # Should not be reported
      class BaseHelper; end # Should be reported
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 1 warning:
      [3]:UncommunicativeModuleName: BaseHelper has the name 'BaseHelper'
    """

  Scenario: UncommunicativeParameterName
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        UncommunicativeParameterName:
          accept:
            - x
            - arg1
          reject:
            - foobar
      """
    And a file named "smelly.rb" with:
      """
      def omg(x); x; end # Should not be reported
      def omg(arg1); arg1; end # Should not be reported
      def omg(foobar); foobar; end # Should be reported
      """
    When I run reek -c config.reek smelly.rb
    Then it reports:
    """
    smelly.rb -- 1 warning:
      [3]:UncommunicativeParameterName: omg has the parameter name 'foobar'
    """
