Feature:

  Write a Reek configuration as a kind of todo list that will prevent Reek
  from reporting smells on the current code.
  This can then be worked on later on.
  The main goal here would be to ease the Reek adoption by allowing developers to:
    - introduce Reek right away (e.g. for CI)
    - exclude the "old" smells from getting reported
    - fix them step by step
    - get rid of the todo file

  Background:
    Given a directory 'lib' with one clean file 'clean.rb' and one dirty file 'dirty.rb'
    And a directory 'superclean' with one clean file 'clean.rb'

  Scenario: Generate a proper todo file that disables all found smells
    When I run reek lib
    Then the exit status indicates smells
    And it reports:
      """
      lib/dirty.rb -- 3 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [3]:UncommunicativeMethodName: Dirty#b has the name 'b' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      3 total warnings
      """
    When I run reek --todo lib
    Then it succeeds
    And a file named ".todo.reek" should exist
    And the file ".todo.reek" should contain:
      """
      ---
      IrresponsibleModule:
        exclude:
        - Dirty
      UncommunicativeMethodName:
        exclude:
        - Dirty#a
        - Dirty#b
        """
    When I run reek -c .todo.reek lib
    Then it succeeds

  Scenario: Respects an configuration file
    Given a configuration file 'config.reek' that partially masks 'dirty.rb'
    When I run reek -c config.reek --todo lib
    Then it succeeds
    And a file named ".todo.reek" should exist
    And the file ".todo.reek" should contain:
      """
      ---
      UncommunicativeMethodName:
        exclude:
        - Dirty#a
      """

  Scenario: Print out a helpful message that explains to the user what to do next
    When I run reek --todo lib
    Then it reports:
      """

      '.todo.reek' generated! You can now use this as a starting point for your configuration.
      """

  Scenario: Reacts appropiately when there are no smells
    When I run reek --todo superclean/
    Then a file named ".todo.reek" should not exist
    And it reports:
      """

      '.todo.reek' not generated because there were no smells found!
      """
