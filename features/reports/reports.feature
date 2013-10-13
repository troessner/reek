@reports
Feature: Correctly formatted reports
  In order to get the most out of reek
  As a developer
  I want to be able to parse reek's output simply and consistently

  Scenario Outline: two reports run together with indented smells
    When I run reek <args>
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/two_smelly_files/dirty_one.rb -- 6 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [4, 6]:Dirty#a calls @s.title twice (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
        [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      spec/samples/two_smelly_files/dirty_two.rb -- 6 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [4, 6]:Dirty#a calls @s.title twice (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
        [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      12 total warnings
      """

    Examples:
      | args                               |
      | spec/samples/two_smelly_files/*.rb |
      | spec/samples/two_smelly_files      |

  Scenario Outline: good files show headers consecutively
    When I run reek <args>
    Then it succeeds
    And it reports:
      """
      spec/samples/three_clean_files/clean_one.rb -- 0 warnings
      spec/samples/three_clean_files/clean_three.rb -- 0 warnings
      spec/samples/three_clean_files/clean_two.rb -- 0 warnings
      0 total warnings
      """

    Examples:
      | args |
      | spec/samples/three_clean_files/*.rb |
      | spec/samples/three_clean_files      |

  Scenario Outline: --quiet turns off headers for fragrant files
    When I run reek <option> spec/samples/three_clean_files/*.rb
    Then it succeeds
    And it reports:
    """
    0 total warnings
    """

    Examples:
      | option  |
      | -q      |
      | --quiet |
      | -n -q   |
      | -q -n   |

  Scenario Outline: --line-number turns off line numbers
    When I run reek <option> spec/samples/not_quite_masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/not_quite_masked/dirty.rb -- 5 warnings:
        Dirty has the variable name '@s' (UncommunicativeVariableName)
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
        Dirty#a has the name 'a' (UncommunicativeMethodName)
      """

    Examples:
      | option        |
      | -n            |
      | --line-number |
      | -n -q         |
      | -q -n         |

  Scenario Outline: --single-line shows filename and one line number
    When I run reek <option> spec/samples/not_quite_masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/not_quite_masked/dirty.rb -- 5 warnings:
        spec/samples/not_quite_masked/dirty.rb:7: Dirty has the variable name '@s' (UncommunicativeVariableName)
        spec/samples/not_quite_masked/dirty.rb:6: Dirty#a calls @s.title twice (DuplicateMethodCall)
        spec/samples/not_quite_masked/dirty.rb:6: Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        spec/samples/not_quite_masked/dirty.rb:7: Dirty#a contains iterators nested 2 deep (NestedIterators)
        spec/samples/not_quite_masked/dirty.rb:5: Dirty#a has the name 'a' (UncommunicativeMethodName)
      """

    Examples:
      | option        |
      | -s            |
      | --single-line |
      | -s -q         |
      | -q -s         |

  Scenario Outline: Extra slashes aren't added to directory names
    When I run reek <args>
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/two_smelly_files/dirty_one.rb -- 6 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [4, 6]:Dirty#a calls @s.title twice (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
        [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      spec/samples/two_smelly_files/dirty_two.rb -- 6 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [4, 6]:Dirty#a calls @s.title twice (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
        [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      12 total warnings
      """

    Examples:
      | args |
      | spec/samples/two_smelly_files/ |
      | spec/samples/two_smelly_files  |
