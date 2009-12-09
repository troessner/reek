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
          parameters: 
          - "@s"
          subclass: UncommunicativeVariableName
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
          parameters: 
          - "@s.title"
          subclass: DuplicateMethodCall
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
          parameters: 
          - puts(@s.title)
          subclass: DuplicateMethodCall
          message: calls puts(@s.title) twice
      - !ruby/object:Reek::SmellWarning 
        is_masked: true
        location: 
          lines: 
          - 3
          context: Dirty#a
          source: spec/samples/masked/dirty.rb
        smell: 
          class: UncommunicativeName
          parameters: 
          - a
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
          parameters: 
          - x
          subclass: UncommunicativeVariableName
          message: has the variable name 'x'
      - !ruby/object:Reek::SmellWarning 
        is_masked: false
        location: 
          lines: 
          - 5
          context: Dirty#a/block/block
          source: spec/samples/masked/dirty.rb
        smell: 
          class: NestedIterators
          parameters: []

          subclass: ""
          message: is nested

      """
