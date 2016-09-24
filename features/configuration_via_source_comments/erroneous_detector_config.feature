Feature: Erroneous source comments are handled properly
  Erroneous source comments should be handled in a way that is intuitive and helpful
  for the user. Reek should neither crash nor silently swallow it.
  If there is something wrong - no matter how small it is - Reek should report it back
  to the user right away so the user can actually do something about it.
  If a user tries to configure a smell detector with unknown or bad parameters
  we should just skip this file and tell the user about it so he can fix it and then
  re-run Reek.

  Scenario: Garbage as content
    Given a file named "bad_detector_config.rb" with:
      """
      # Test class
      # :reek:UncommunicativeMethodName { thats a bad config }
      def x
      end
      """
    When I run reek bad_detector_config
    Then it reports the error "Error: TODO: Line, original comment"

  Scenario: Unknown configuration key
    Given a file named "bad_detector_config.rb" with:
      """
      TODO
      """
    When I run reek bad_detector_config
    Then it reports the error "Error: TODO"

  Scenario: Bad value for basic option "enabled"
    Given a file named "bad_detector_config.rb" with:
      """
      TODO
      """
    When I run reek bad_detector_config
    Then it reports the error "Error: TODO"

  Scenario: Bad value for basic option "exclude"
    Given a file named "bad_detector_config.rb" with:
      """
      TODO
      """
    When I run reek bad_detector_config
    Then it reports the error "Error: TODO"

  Scenario: Bad value for custom option "TODO"
    Given a file named "bad_detector_config.rb" with:
      """
      TODO
      """
    When I run reek bad_detector_config
    Then it reports the error "Error: TODO"
