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
    And it reports:
      """


      """

  Scenario: return non-zero status when there are smells
    When I pass "class Turn; def y() @x = 3; end end" to reek
    Then it fails with exit status 2
    And it reports:
      """
      $stdin -- 2 warnings:
        Turn has the variable name '@x' (Uncommunicative Name)
        Turn#y has the name 'y' (Uncommunicative Name)

      """
