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

    Examples:
      | args                               |
      | spec/samples/two_smelly_files/*.rb |
      | spec/samples/two_smelly_files      |

  Scenario: Do not sort by default (which means report each file as it is read in)
    When I run reek spec/samples/three_smelly_files/*.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/three_smelly_files/dirty_one.rb -- 2 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      spec/samples/three_smelly_files/dirty_three.rb -- 4 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
        [4]:Dirty#c has the name 'c' (UncommunicativeMethodName)
      spec/samples/three_smelly_files/dirty_two.rb -- 3 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
      9 total warnings
      """

  Scenario Outline: Sort by issue count
    When I run reek <option> spec/samples/three_smelly_files/*.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/three_smelly_files/dirty_three.rb -- 4 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
        [4]:Dirty#c has the name 'c' (UncommunicativeMethodName)
      spec/samples/three_smelly_files/dirty_two.rb -- 3 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
      spec/samples/three_smelly_files/dirty_one.rb -- 2 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      9 total warnings
      """

    Examples:
      | option                |
      | -S                    |
      | --sort-by-issue-count |

  Scenario Outline: good files show no headers by default
    When I run reek <args>
    Then it succeeds
    And it reports:
      """

      0 total warnings
      """

    Examples:
      | args |
      | spec/samples/three_clean_files/*.rb |
      | spec/samples/three_clean_files      |

  Scenario Outline: --verbose and --no-quiet turn on headers for fragrant files
    When I run reek <option> spec/samples/three_clean_files/*.rb
    Then it succeeds
    And it reports:
      """
      spec/samples/three_clean_files/clean_one.rb -- 0 warnings
      spec/samples/three_clean_files/clean_three.rb -- 0 warnings
      spec/samples/three_clean_files/clean_two.rb -- 0 warnings
      0 total warnings
      """

    Examples:
      | option     |
      | --verbose  |
      | -V         |
      | --no-quiet |

  Scenario Outline: --quiet turns off headers for fragrant files
    When I run reek <option> spec/samples/three_clean_files/*.rb
    Then it succeeds
    And it reports:
    """

    0 total warnings
    """

    Examples:
      | option        |
      | -V -q         |
      | -V --quiet    |

  Scenario Outline: --line-number turns off line numbers
    When I run reek <option> spec/samples/standard_smelly/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/standard_smelly/dirty.rb -- 6 warnings:
        Dirty has the variable name '@s' (UncommunicativeVariableName)
        Dirty#a calls @s.title 2 times (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
        Dirty#a has the name 'a' (UncommunicativeMethodName)
        Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      """

    Examples:
      | option            |
      | -n                |
      | --no-line-numbers |
      | -n -V             |
      | -V -n             |

  Scenario Outline: --single-line shows filename and one line number
    When I run reek <option> spec/samples/standard_smelly/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/standard_smelly/dirty.rb -- 6 warnings:
        spec/samples/standard_smelly/dirty.rb:5: Dirty has the variable name '@s' (UncommunicativeVariableName)
        spec/samples/standard_smelly/dirty.rb:4: Dirty#a calls @s.title 2 times (DuplicateMethodCall)
        spec/samples/standard_smelly/dirty.rb:4: Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
        spec/samples/standard_smelly/dirty.rb:5: Dirty#a contains iterators nested 2 deep (NestedIterators)
        spec/samples/standard_smelly/dirty.rb:3: Dirty#a has the name 'a' (UncommunicativeMethodName)
        spec/samples/standard_smelly/dirty.rb:5: Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      """

    Examples:
      | option        |
      | -s            |
      | --single-line |
      | -s -V         |
      | -V -s         |

  Scenario Outline: Extra slashes aren't added to directory names
    When I run reek <args>
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

    Examples:
      | args |
      | spec/samples/two_smelly_files/ |
      | spec/samples/two_smelly_files  |

  Scenario Outline: -U or --ultra-verbose adds helpful links to smell warnings
    When I run reek <option> spec/samples/one_smelly_file/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/one_smelly_file/dirty.rb -- 3 warnings:
        [1]:D has no descriptive comment (IrresponsibleModule) [https://github.com/troessner/reek/wiki/Irresponsible-Module]
        [1]:D has the name 'D' (UncommunicativeModuleName) [https://github.com/troessner/reek/wiki/Uncommunicative-Module-Name]
        [2]:D#a has the name 'a' (UncommunicativeMethodName) [https://github.com/troessner/reek/wiki/Uncommunicative-Method-Name]
      """

    Examples:
      | option           |
      | -U               |
      | --ultra-verbose  |
