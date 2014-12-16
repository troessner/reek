@yaml
Feature: Report smells using simple YAML layout
  In order to parse reek's output simply and consistently, simply
  output a list of smells in Yaml.

  Scenario: output is empty when there are no smells
    When I run reek --yaml spec/samples/three_clean_files
    Then it succeeds
    And it reports this yaml:
    """
    --- []
    """

  @masking
  Scenario: masked smells always appear
    When I run reek --yaml spec/samples/masked/dirty.rb
    Then the exit status indicates smells
    And it reports this yaml:
      """
      ---
      - smell_category: Duplication
        smell_type: DuplicateMethodCall
        source: spec/samples/masked/dirty.rb
        context: Dirty#a
        lines:
        - 4
        - 6
        message: calls @s.title 2 times
        name: "@s.title"
        count: 2
      - smell_category: Duplication
        smell_type: DuplicateMethodCall
        source: spec/samples/masked/dirty.rb
        context: Dirty#a
        lines:
        - 4
        - 6
        message: calls puts(@s.title) 2 times
        name: puts(@s.title)
        count: 2
      - smell_category: NestedIterators
        smell_type: NestedIterators
        source: spec/samples/masked/dirty.rb
        context: Dirty#a
        lines:
        - 5
        message: contains iterators nested 2 deep
        count: 2
      """

  @stdin
  Scenario: return non-zero status when there are smells
    When I pass "class Turn; end" to reek --yaml
    Then the exit status indicates smells
    And it reports this yaml:
      """
      ---
      - smell_category: IrresponsibleModule
        smell_type: IrresponsibleModule
        source: "$stdin"
        context: Turn
        lines:
        - 1
        message: has no descriptive comment
        name: Turn
      """
