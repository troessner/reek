Feature: Erroneous configuration is handled properly
  Erroneous configuration should be handled in a way that is intuitive and helpful
  for the user. Reek should neither crash nor silently swallow it.
  If there is something wrong - no matter how small it is - Reek should report it back
  to the user right away so the user can actually do something about it.

  Scenario: Unknown smell detector
    Given a file named "config.reek" with:
      """
      ---
      DoesNotExist:
        enabled: false
      """
    Given the smelly file 'smelly.rb'
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates an error
    And it reports the error "TODO"
    And there is no output on stdout

  Scenario: Mispelled basic configuration option ("ixclude" vs "exclude")
    Given a file named "config.reek" with:
      """
      ---
      DuplicateMethodCall:
        ixclude:
        - write
      """
    Given the smelly file 'smelly.rb'
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates an error
    And it reports the error "TODO"
    And there is no output on stdout

  Scenario: Non-existent configuration option
    Given a file named "config.reek" with:
      """
      ---
      DuplicateMethodCall:
        does_not_exist: true
      """
    Given the smelly file 'smelly.rb'
    When I run reek -c config.reek smelly.rb
    Then the exit status indicates an error
    And it reports the error "TODO"
    And there is no output on stdout
