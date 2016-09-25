Feature: Erroneous source comments are handled properly
  Erroneous source comments should be handled in a way that is intuitive and helpful
  for the user. Reek should neither crash nor silently swallow it.
  If there is something wrong - no matter how small it is - Reek should report it back
  to the user right away so the user can actually do something about it.
  If a user tries to deactivate an unknown smell detector (e.g. because he made a typo)
  we should just skip this file and tell the user about it so he can fix it and then
  re-run Reek.

  Scenario: Unknown smell detector
    Given a file named "bad_detector.rb" with:
      """
      # Test class
      # :reek:UnknownDetectorName
      def x
      end
      """
    When I run reek bad_detector.rb
    Then it reports the error "Error: You are trying to configure an unknown smell detector 'UnknownDetectorName'"

  Scenario: Unknown smell detector - one good file, one bad file
    Given a file named "bad_detector.rb" with:
      """
      # Test class
      # :reek:UnknownDetectorName
      def x
      end
      """
    Given the smelly file 'smelly.rb'
    When I run reek bad_detector.rb smelly.rb
    Then it reports the error "Error: You are trying to configure an unknown smell detector 'UnknownDetectorName'"
    And the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
      2 total warnings
      """
