@smells_count
Feature: Reports total number of code smells
  In order to monitor the total number of smells
  Reek outputs the total number of smells among all files inspected.

  Scenario: Does not output total number of smells when inspecting single file
    When I run reek spec/samples/standard_smelly/dirty.rb
    Then the exit status indicates smells
    And it reports:
    """
    spec/samples/standard_smelly/dirty.rb -- 6 warnings:
      [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
      [4, 6]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
      [4, 6]:Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
      [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
      [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
    """

  Scenario: Output total number of smells when inspecting multiple files
    When I run reek spec/samples/two_smelly_files
    Then the exit status indicates smells
    And it reports:
    """
    spec/samples/two_smelly_files/dirty_one.rb -- 6 warnings:
      [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
      [4, 6]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
      [4, 6]:Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
      [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
      [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
    spec/samples/two_smelly_files/dirty_two.rb -- 6 warnings:
      [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
      [4, 6]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
      [4, 6]:Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
      [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
      [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
    12 total warnings
    """

  Scenario: Output total number of smells even if total equals 0
    When I run reek spec/samples/three_clean_files
    Then it succeeds
    And it reports:
    """

    0 total warnings
    """
