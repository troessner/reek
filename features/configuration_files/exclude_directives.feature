Feature: Exclude directives
  In order to have a more fine-grained control over what Reek reports
  As a user
  I want to be able to exclude specific contexts from reporting

  Scenario: Exclude multiple contexts
    Given a file named "config.reek" with:
      """
      ---
      UncommunicativeMethodName:
        exclude:
          - "Smelly#x"
      UnusedPrivateMethod:
        enabled: true
        exclude:
          - "Smelly#foobar"
      """
    And a file named "smelly.rb" with:
      """
      class Smelly
        # Should report IrresponsibleModule
        def foo(arg); end # Should report UnusedParameter
        def x; end        # Should not report UncommunicativeMethodName
        private
        def foobar; end   # Should not report UnusedPrivateMethod
      end
      """
    When I run `reek -c config.reek smelly.rb`
    Then it reports:
    """
    smelly.rb -- 2 warnings:
      [1]:IrresponsibleModule: Smelly has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
      [3]:UnusedParameters: Smelly#foo has unused parameter 'arg' [https://github.com/troessner/reek/blob/master/docs/Unused-Parameters.md]
    """
