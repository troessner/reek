@stdin
Feature: Reek reads from $stdin when no files are given
  In order to use reek with pipelines
  As a developer
  I want to pipe source code on stdin

  Scenario: return zero status with no smells
    When I pass "def simple() @fred = 3 end" to reek
    Then it succeeds
    And it reports:
      """
      $stdin -- 0 warnings

      """

  Scenario: outputs header only on empty stdin
    When I pass "" to reek
    Then it succeeds
    And it reports:
      """
      $stdin -- 0 warnings

      """

  Scenario: outputs nothing on empty stdin in quiet mode
    When I pass "" to reek --quiet
    Then it succeeds
    And stdout equals ""

  Scenario: return non-zero status when there are smells
    When I pass "class Turn; def y() @x = 3; end end" to reek
    Then the exit status indicates smells
    And it reports:
      """
      $stdin -- 3 warnings:
        [1]:Turn has no descriptive comment (IrresponsibleModule)
        [1]:Turn has the variable name '@x' (UncommunicativeVariableName)
        [1]:Turn#y has the name 'y' (UncommunicativeMethodName)

      """

  @stderr
  Scenario: syntax error causes the source to be ignored
    When I pass "def incomplete" to reek
    Then it succeeds
    And it reports:
      """
      $stdin -- 0 warnings

      """
    And it reports a parsing error

