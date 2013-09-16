@yaml
Feature: Report smells using simple YAML layout
  In order to parse reek's output simply and consistently, simply
  output a list of smells in Yaml.

  Scenario: output is empty when there are no smells
    When I run reek --yaml spec/samples/three_clean_files
    Then it succeeds
    And stdout equals ""

  @masking
  Scenario: masked smells always appear
    When I run reek --yaml spec/samples/masked/dirty.rb
    Then the exit status indicates smells
    And it reports this yaml:
      """
      --- 
      - !ruby/object:Reek::SmellWarning 
        location: 
          lines: 
          - 4
          - 6
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          class: Duplication
          occurrences: 2
          subclass: DuplicateMethodCall
          call: "@s.title"
          message: calls @s.title twice
        status: 
          is_active: true
      - !ruby/object:Reek::SmellWarning 
        location: 
          lines: 
          - 5
          - 7
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          class: Duplication
          occurrences: 2
          subclass: DuplicateMethodCall
          call: puts(@s.title)
          message: calls puts(@s.title) twice
        status: 
          is_active: true
      - !ruby/object:Reek::SmellWarning 
        location: 
          lines: 
          - 5
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          class: NestedIterators
          depth: 2
          subclass: NestedIterators
          message: contains iterators nested 2 deep
        status: 
          is_active: true

      """

  @stdin
  Scenario: return non-zero status when there are smells
    When I pass "class Turn; end" to reek --yaml
    Then the exit status indicates smells
    And it reports this yaml:
      """
      --- 
      - !ruby/object:Reek::SmellWarning 
        location: 
          lines: 
          - 1
          context: Turn
          source: $stdin
        smell: 
          class: IrresponsibleModule
          subclass: IrresponsibleModule
          module_name: Turn
          message: has no descriptive comment
        status: 
          is_active: true

      """
