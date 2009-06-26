@options
Feature: Reek can be controlled using command-line options
  In order to change reek's default behaviour
  As a developer
  I want to supply options on the command line

  Scenario: return non-zero status on bad option
    When I run reek --no-such-option
    Then it fails with exit status 1
    And it displays the error message:
      """
      Error: invalid option: --no-such-option

      """

  Scenario: return non-zero status on missing argument
    When I run reek -f
    Then it fails with exit status 1
    And it displays the error message:
      """
      Error: missing argument: -f

      """

  Scenario: display the current version number
    When I run reek --version
    Then it succeeds
    And it reports the current version
