@stdin
Feature: Reek reads from $stdin when no files are given
  In order to use reek with pipelines
  As a developer
  I want to pipe source code on stdin

  Scenario: return zero status with no smells
    When I pass "def simple() @fred = 3 end" to reek
    Then it succeeds

  Scenario: outputs nothing on empty stdin
    When I pass "" to reek
    Then it succeeds
    And stdout equals ""

  Scenario: return non-zero status when there are smells
    When I pass "def x() 3; end" to reek
    Then it fails with exit status 2

  Scenario: output nothing when no smells
    When I pass "def simple() @fred = 3; end" to reek
    Then it succeeds
    And stdout equals ""

  Scenario: report smells correctly
    When I pass "class Turn; def y() @x = 3; end end" to reek
    Then it fails with exit status 2
    And it reports:
      """
        Turn has the variable name '@x' (Uncommunicative Name)
        Turn#y has the name 'y' (Uncommunicative Name)

      """
