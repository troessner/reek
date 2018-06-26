Feature: Unused Private Method detector
  This detector is a little special in the sense that it takes class contexts but analyzes
  methods (and thus, is configured in regards to methods) so we need to make sure
  that our configuration handling still works.

  Scenario: Differentiate between contexts when excluding them
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        IrresponsibleModule:
          enabled: false
        UnusedPrivateMethod:
          enabled: true
          exclude:
            - Outer::Awesome#foobar
      """
    And a file named "sample.rb" with:
      """
      module Outer
        class Smelly
          private
          def foobar; end # Should report UnusedPrivateMethod
        end
        class Awesome
          private
          def foobar; end # Should not report UnusedPrivateMethod
        end
      end
      """
    When I run reek -c config.reek sample.rb
    Then it reports:
    """
    sample.rb -- 1 warning:
      [4]:UnusedPrivateMethod: Outer::Smelly has the unused private instance method 'foobar'
    """

  Scenario: Use regexes for excluding contexts
    Given a file named "config.reek" with:
      """
      ---
      detectors:
        IrresponsibleModule:
          enabled: false
        UnusedPrivateMethod:
          enabled: true
          exclude:
            - wesome#foo
      """
    And a file named "sample.rb" with:
      """
      module Outer
        class Smelly
          private
          def foobar; end # Should report UnusedPrivateMethod
        end
        class Awesome
          private
          def foobar; end # Should not report UnusedPrivateMethod
        end
      end
      """
    When I run reek -c config.reek sample.rb
    Then it reports:
    """
    sample.rb -- 1 warning:
      [4]:UnusedPrivateMethod: Outer::Smelly has the unused private instance method 'foobar'
    """
