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
        context: Dirty
        is_masked: true
        line: 1
        message: has the variable name '@s'
        smell: UncommunicativeName
      - !ruby/object:Reek::SmellWarning 
        context: Dirty#a
        is_masked: false
        line: 2
        message: calls @s.title twice
        smell: Duplication
      - !ruby/object:Reek::SmellWarning 
        context: Dirty#a
        is_masked: false
        line: 2
        message: calls puts(@s.title) twice
        smell: Duplication
      - !ruby/object:Reek::SmellWarning 
        context: Dirty#a
        is_masked: true
        line: 2
        message: has the name 'a'
        smell: UncommunicativeName
      - !ruby/object:Reek::SmellWarning 
        context: Dirty#a/block
        is_masked: true
        line: 4
        message: has the variable name 'x'
        smell: UncommunicativeName
      - !ruby/object:Reek::SmellWarning 
        context: Dirty#a/block/block
        is_masked: false
        line: 4
        message: is nested
        smell: NestedIterators

      """
