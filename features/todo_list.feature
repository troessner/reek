Feature:

  Write a Reek configuration as a kind of todo list that will prevent Reek
  from reporting smells on the current code.
  This can then be worked on later on.
  The main goal here would be to ease the Reek adoption by allowing developers to:
    - introduce Reek right away (e.g. for CI)
    - exclude the "old" smells from getting reported
    - fix them step by step
    - get rid of the todo file

  Scenario: Generate a proper todo file that disables all found smells
    Given a smelly file called 'smelly.rb'
    When I run reek smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """
    When I run reek --todo smelly.rb
    Then it succeeds
    And it reports:
      """

      '.todo.reek' generated! You can now use this as a starting point for your configuration.
      """
    And a file named ".todo.reek" should exist
    And the file ".todo.reek" should contain:
      """
      ---
      DuplicateMethodCall:
        exclude:
        - Smelly#m
      UncommunicativeMethodName:
        exclude:
        - Smelly#m
        """
    When I run reek -c .todo.reek smelly.rb
    Then it succeeds

  Scenario: Respects a configuration file
    Given a smelly file called 'smelly.rb'
    And a configuration file disabling DuplicateMethodCall called 'config.reek'
    When I run reek -c config.reek --todo smelly.rb
    Then it succeeds
    And a file named ".todo.reek" should exist
    And the file ".todo.reek" should contain:
      """
      ---
      UncommunicativeMethodName:
        exclude:
        - Smelly#m
      """

  Scenario: Reacts appropiately when there are no smells
    Given the clean file 'clean.rb'
    When I run reek --todo clean.rb
    Then a file named ".todo.reek" should not exist
    And it reports:
      """

      '.todo.reek' not generated because there were no smells found!
      """
