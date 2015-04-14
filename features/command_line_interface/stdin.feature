Feature: Reek reads from $stdin when no files are given
  In order to use reek with pipelines
  As a developer
  I want to pipe source code on stdin

  Scenario: return zero status with no smells
    When I pass "def simple() @fred = 3 end" to reek
    Then it succeeds
    And it reports nothing

  Scenario: outputs nothing on empty stdin
    When I pass "" to reek
    Then it succeeds
    And it reports nothing

  Scenario: outputs header only on empty stdin in verbose mode
    When I pass "" to reek -V
    Then it succeeds
    And it reports:
      """
      STDIN -- 0 warnings
      """

  Scenario: return non-zero status when there are smells
    When I pass "class Turn; def y() @x = 3; end end" to reek
    Then the exit status indicates smells
    And it reports:
      """
      STDIN -- 3 warnings:
        [1]:Turn has no descriptive comment (IrresponsibleModule)
        [1]:Turn has the variable name '@x' (UncommunicativeVariableName)
        [1]:Turn#y has the name 'y' (UncommunicativeMethodName)
      """

  Scenario: syntax error causes the source to be ignored
    When I pass "def incomplete" to reek
    Then it reports a parsing error
    Then it succeeds
    And it reports nothing
