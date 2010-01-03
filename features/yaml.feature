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
    And it reports:
      """
      --- 
      - !ruby/object:Reek::SmellWarning 
        is_masked: true
        location: 
          lines: 
          - 2
          context: Dirty
          source: spec/samples/masked/dirty.rb
        smell: 
          class: UncommunicativeName
          subclass: UncommunicativeVariableName
          variable_name: "@s"
          message: has the variable name '@s'
      - !ruby/object:Reek::SmellWarning 
        is_masked: false
        location: 
          lines: 
          - 3
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          class: Duplication
          occurrences: 2
          subclass: DuplicateMethodCall
          call: "@s.title"
          message: calls @s.title twice
      - !ruby/object:Reek::SmellWarning 
        is_masked: false
        location: 
          lines: 
          - 3
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          class: Duplication
          occurrences: 2
          subclass: DuplicateMethodCall
          call: puts(@s.title)
          message: calls puts(@s.title) twice
      - !ruby/object:Reek::SmellWarning 
        is_masked: false
        location: 
          lines: 
          - 5
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          class: NestedIterators
          depth: 2
          subclass: ""
          message: contains iterators nested 2 deep
      - !ruby/object:Reek::SmellWarning 
        is_masked: true
        location: 
          lines: 
          - 3
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          method_name: a
          class: UncommunicativeName
          subclass: UncommunicativeMethodName
          message: has the name 'a'
      - !ruby/object:Reek::SmellWarning 
        is_masked: true
        location: 
          lines: 
          - 5
          context: Dirty#a/block
          source: spec/samples/masked/dirty.rb
        smell: 
          class: UncommunicativeName
          subclass: UncommunicativeVariableName
          variable_name: x
          message: has the variable name 'x'

      """

  @stdin
  Scenario: return non-zero status when there are smells
    When I pass "# test class\nclass Turn; def fred(arg = true) end end" to reek --yaml
    Then the exit status indicates smells
    And it reports:
      """
      --- 
      - !ruby/object:Reek::SmellWarning 
        is_masked: false
        location: 
          lines: 
          - 2
          context: Turn#fred
          source: $stdin
        smell: 
          parameter: arg
          class: ControlCouple
          subclass: BooleanParameter
          message: has boolean parameter arg

      """
