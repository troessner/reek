Feature: Correctly formatted reports
  In order to get the most out of reek
  As a developer
  I want to be able to parse reek's output simply and consistently

  Scenario Outline: two reports run together with indented smells
    Given a directory called 'smelly' containing two smelly files
    When I run reek <args>
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      smelly/dirty_two.rb -- 3 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
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
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      smelly/dirty_two.rb -- 3 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
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
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
      smelly/dirty_one.rb -- 2 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
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
        Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        Smelly#m has the name 'm' (UncommunicativeMethodName)
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
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName)
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
        smelly.rb:4: Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        smelly.rb:4: Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        smelly.rb:3: Smelly#m has the name 'm' (UncommunicativeMethodName)
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
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      smelly/dirty_two.rb -- 3 warnings:
        [1]:Dirty has no descriptive comment (IrresponsibleModule)
        [2]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [3]:Dirty#b has the name 'b' (UncommunicativeMethodName)
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
        [4, 5]:Smelly#m calls @foo.bar 2 times (DuplicateMethodCall) [https://github.com/troessner/reek/wiki/Duplicate-Method-Call]
        [4, 5]:Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall) [https://github.com/troessner/reek/wiki/Duplicate-Method-Call]
        [3]:Smelly#m has the name 'm' (UncommunicativeMethodName) [https://github.com/troessner/reek/wiki/Uncommunicative-Method-Name]
      """

    Examples:
      | option           |
      | -U               |
      | --wiki-links  |

  Scenario Outline: --wiki-links is independent of --line-numbers
    Given a smelly file called 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 3 warnings:
        Smelly#m calls @foo.bar 2 times (DuplicateMethodCall) [https://github.com/troessner/reek/wiki/Duplicate-Method-Call]
        Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall) [https://github.com/troessner/reek/wiki/Duplicate-Method-Call]
        Smelly#m has the name 'm' (UncommunicativeMethodName) [https://github.com/troessner/reek/wiki/Uncommunicative-Method-Name]
      """

    Examples:
      | option                             |
      | --no-line-numbers -U               |
      | --no-line-numbers --wiki-links  |
