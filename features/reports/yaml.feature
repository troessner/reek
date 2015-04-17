Feature: Report smells using simple YAML layout
  In order to parse reek's output simply and consistently, simply
  output a list of smells in Yaml.

  Scenario: output is empty when there are no smells
    Given a directory called 'clean_files' containing some clean files
    When I run reek --format yaml clean_files
    Then it succeeds
    And it reports this yaml:
    """
    --- []
    """

  Scenario: Indicate smells and print them as yaml when using files
    Given a smelly file called 'smelly.rb'
    When I run reek --format yaml smelly.rb
    Then the exit status indicates smells
    And it reports this yaml:
      """
      ---
      - smell_category: Duplication
        smell_type: DuplicateMethodCall
        source: smelly.rb
        context: Smelly#m
        lines:
        - 4
        - 5
        message: calls @foo.bar 2 times
        name: "@foo.bar"
        count: 2
      - smell_category: Duplication
        smell_type: DuplicateMethodCall
        source: smelly.rb
        context: Smelly#m
        lines:
        - 4
        - 5
        message: calls puts(@foo.bar) 2 times
        name: puts(@foo.bar)
        count: 2
      - smell_category: UncommunicativeName
        smell_type: UncommunicativeMethodName
        source: smelly.rb
        context: Smelly#m
        lines:
        - 3
        message: has the name 'm'
        name: m
      """

  Scenario: Indicate smells and print them as yaml when using STDIN
    When I pass "class Turn; end" to reek --format yaml
    Then the exit status indicates smells
    And it reports this yaml:
      """
      ---
      - smell_category: IrresponsibleModule
        smell_type: IrresponsibleModule
        source: "STDIN"
        context: Turn
        lines:
        - 1
        message: has no descriptive comment
        name: Turn
      """
