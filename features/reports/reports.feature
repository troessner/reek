Feature: Correctly formatted reports
  In order to get the most out of Reek
  As a developer
  I want to be able to parse Reek's output simply and consistently

  Scenario Outline: two reports run together with indented smells
    Given a directory called 'smelly' containing two smelly files
    When I run reek <args>
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      smelly/dirty_two.rb -- 3 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [3]:UncommunicativeMethodName: Dirty#b has the name 'b' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      5 total warnings
      """

    Examples:
      | args                                    |
      | smelly/dirty_one.rb smelly/dirty_two.rb |
      | smelly                                  |

  Scenario Outline: No sorting (which means report each file as it is read in)
    Given a directory called 'smelly' containing two smelly files
    When I run reek <option> smelly
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      smelly/dirty_two.rb -- 3 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [3]:UncommunicativeMethodName: Dirty#b has the name 'b' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      5 total warnings
      """

    Examples:
      | option         |
      |                |
      | --sort-by none |
      | --sort-by n    |

  Scenario Outline: Sort by issue count
    Given a directory called 'smelly' containing two smelly files
    When I run reek <option> smelly
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_two.rb -- 3 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [3]:UncommunicativeMethodName: Dirty#b has the name 'b' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      smelly/dirty_one.rb -- 2 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      5 total warnings
      """

    Examples:
      | option               |
      | --sort-by smelliness |
      | --sort-by s          |

  Scenario: good files show no headings by default
    Given a directory called 'clean_files' containing some clean files
    When I run reek clean_files
    Then it succeeds
    And it reports:
      """
      0 total warnings
      """

  Scenario Outline: --empty-headings turns on headings for fragrant files
    Given a directory called 'clean_files' containing some clean files
    When I run reek <option> clean_files
    Then it succeeds
    And it reports:
      """
      clean_files/clean_one.rb -- 0 warnings
      clean_files/clean_three.rb -- 0 warnings
      clean_files/clean_two.rb -- 0 warnings
      0 total warnings
      """

    Examples:
      | option            |
      | --empty-headings  |
      | -V                |

  Scenario Outline: --no-empty-headings turns off headings for fragrant files
    Given a directory called 'clean_files' containing some clean files
    When I run reek <option> clean_files
    Then it succeeds
    And it reports:
      """
      0 total warnings
      """

    Examples:
      | option                 |
      | --no-empty-headings    |
      | -V --no-empty-headings |

  Scenario Outline: --no-line-numbers turns off line numbers
    Given a smelly file called 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        DuplicateMethodCall: Smelly#m calls puts(@foo.bar) 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

    Examples:
      | option               |
      | --no-line-numbers    |
      | --no-line-numbers -V |
      | -V --no-line-numbers |

  Scenario Outline: --line-numbers turns on line numbers
    Given a smelly file called 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts(@foo.bar) 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

    Examples:
      | option                           |
      | --line-numbers                   |
      | --no-line-numbers --line-numbers |
      | --no-line-numbers -n             |

  Scenario Outline: --single-line shows filename and one line number
    Given a smelly file called 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        smelly.rb:4: DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        smelly.rb:4: DuplicateMethodCall: Smelly#m calls puts(@foo.bar) 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        smelly.rb:3: UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

    Examples:
      | option        |
      | -s            |
      | --single-line |
      | -s -V         |
      | -V -s         |

  Scenario Outline: Extra slashes aren't added to directory names
    Given a directory called 'smelly' containing two smelly files
    When I run reek <args>
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      smelly/dirty_two.rb -- 3 warnings:
        [1]:IrresponsibleModule: Dirty has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
        [2]:UncommunicativeMethodName: Dirty#a has the name 'a' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
        [3]:UncommunicativeMethodName: Dirty#b has the name 'b' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      5 total warnings
      """

    Examples:
      | args    |
      | smelly/ |
      | smelly  |

  Scenario Outline: -U or --wiki-links adds helpful links to smell warnings
    Given a smelly file called 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts(@foo.bar) 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

    Examples:
      | option        |
      | -U            |
      | --wiki-links  |

  Scenario: --no-wiki-links drops links from smell warnings
    Given a smelly file called 'smelly.rb'
    When I run reek --no-wiki-links smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        [4, 5]:DuplicateMethodCall: Smelly#m calls @foo.bar 2 times
        [4, 5]:DuplicateMethodCall: Smelly#m calls puts(@foo.bar) 2 times
        [3]:UncommunicativeMethodName: Smelly#m has the name 'm'
      """

  Scenario Outline: --wiki-links is independent of --line-numbers
    Given a smelly file called 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        DuplicateMethodCall: Smelly#m calls @foo.bar 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        DuplicateMethodCall: Smelly#m calls puts(@foo.bar) 2 times [https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md]
        UncommunicativeMethodName: Smelly#m has the name 'm' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
      """

    Examples:
      | option                             |
      | --no-line-numbers -U               |
      | --no-line-numbers --wiki-links  |
