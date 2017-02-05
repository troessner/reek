Feature: Exclude paths directives
  In order to avoid Reek wasting time on files that cannot be fixed
  As a user
  I want to be able to exclude specific paths from being checked

  Scenario: Exclude some paths
    Given a file named "bad_files_live_here/smelly.rb" with:
      """
      # A smelly example class
      class Smelly
        def alfa(bravo); end
      end
      """
    When I run `reek .`
    Then the exit status indicates smells
    Given a file named "config.reek" with:
      """
      ---
      exclude_paths:
        - bad_files_live_here
      """
    When I run `reek -c config.reek .`
    Then it succeeds
    And it reports nothing
