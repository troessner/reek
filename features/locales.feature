Feature: Handling different locales
  In order to work in a variety of environments
  As a developer
  I want Reek to work properly in any locale

  Scenario: Running Reek in an UTF-8 locale
    Given I set the environment variable "LANG" to "en_US.utf8"
    And a file "konnichiwa.rb" with:
    """
    puts 'こんにちは世界'
    """
    When I run `reek -V konnichiwa.rb`
    Then it succeeds
    And it reports no errors
    And it reports:
      """
      konnichiwa.rb -- 0 warnings
      """

  Scenario: Running Reek in the POSIX locale
    Given I set the environment variable "LANG" to "POSIX"
    And a file "konnichiwa.rb" with:
    """
    puts 'こんにちは世界'
    """
    When I run `reek -V konnichiwa.rb`
    Then it succeeds
    And it reports no errors
    And it reports:
      """
      konnichiwa.rb -- 0 warnings
      """
