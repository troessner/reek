Feature: Exclude paths directives
  In order to avoid Reek wasting time on files that cannot be fixed
  As a user
  I want to be able to exclude specific paths from being checked

  Scenario: Exclude paths
    Given the smelly file "smelly.rb" in the directory "smelly_sources"
    And the smelly file "smelly.rb" in the directory "smelly_as_well"
    And the smelly file "smelly.rb" in the directory "smelly_as_well_2"
    When I run reek .
    Then the exit status indicates smells
    Given a file named "config.reek" with:
      """
      ---
      exclude_paths:
        - smelly_sources/smelly.rb
        - smelly_as_well/
        - smelly_as_well_2
      """
    When I run reek -c config.reek .
    Then it succeeds
    And it reports nothing

  Scenario: Using a file name within an excluded directory
    Given a file named "bad_files_live_here/smelly.rb" with:
      """
      # A smelly example class
      class Smelly
        def alfa(bravo); end
      end
      """
    And a file named "config.reek" with:
      """
      ---
      exclude_paths:
        - bad_files_live_here
      """
    When I run reek -c config.reek bad_files_live_here/smelly.rb
    Then the exit status indicates smells
    When I run reek -c config.reek --force-exclusion bad_files_live_here/smelly.rb
    Then it succeeds
    And it reports nothing
