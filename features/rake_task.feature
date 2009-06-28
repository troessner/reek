@rake
Feature: RakeTask
  In order to run reek as part of my CI process
  As a developer
  I want to create rake tasks to run reek

  Scenario: reports no smells in reek's own source code
    When I run rake reek
    Then it succeeds
