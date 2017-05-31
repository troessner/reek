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
        [1]:IrresponsibleModule: Turn has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [1]:UncommunicativeMethodName: Turn#y has the name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [1]:UncommunicativeVariableName: Turn has the variable name '@x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      """

  Scenario: syntax error causes the source to be ignored
    When I pass "= invalid syntax =" to reek
    Then the exit status indicates smells
    And it reports:
      """
      STDIN -- 2 warnings:
        [2]:Syntax: This file has unexpected token $end [https://github.com/troessner/reek/blob/master/docs/Syntax.md]
        [1]:Syntax: This file has unexpected token tEQL [https://github.com/troessner/reek/blob/master/docs/Syntax.md]
      """
