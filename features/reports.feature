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
        Dirty has the variable name '@s' (Uncommunicative Name)
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a contains iterators nested 2 deep (Nested Iterators)
        Dirty#a has the name 'a' (Uncommunicative Name)
        Dirty#a has the variable name 'x' (Uncommunicative Name)
      spec/samples/two_smelly_files/dirty_two.rb -- 6 warnings:
        Dirty has the variable name '@s' (Uncommunicative Name)
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a contains iterators nested 2 deep (Nested Iterators)
        Dirty#a has the name 'a' (Uncommunicative Name)
        Dirty#a has the variable name 'x' (Uncommunicative Name)

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

      """

    Examples:
      | args |
      | spec/samples/three_clean_files/*.rb |
      | spec/samples/three_clean_files      |

  Scenario Outline: --quiet turns off headers for fragrant files
    When I run reek <option> spec/samples/three_clean_files/*.rb
    Then it succeeds
    And stdout equals ""

    Examples:
      | option  |
      | -q      |
      | --quiet |


  Scenario Outline: -a turns on details in presence of -q
    When I run reek <options> spec/samples/clean_due_to_masking/*.rb
    Then it succeeds
    And it reports:
      """
      spec/samples/clean_due_to_masking/dirty_one.rb -- 0 warnings (+7 masked):
        (masked) Dirty has no descriptive comment (Irresponsible Module)
        (masked) Dirty has the variable name '@s' (Uncommunicative Name)
        (masked) Dirty#a calls @s.title twice (Duplication)
        (masked) Dirty#a calls puts(@s.title) twice (Duplication)
        (masked) Dirty#a contains iterators nested 2 deep (Nested Iterators)
        (masked) Dirty#a has the name 'a' (Uncommunicative Name)
        (masked) Dirty#a has the variable name 'x' (Uncommunicative Name)
      spec/samples/clean_due_to_masking/dirty_two.rb -- 0 warnings (+7 masked):
        (masked) Dirty has no descriptive comment (Irresponsible Module)
        (masked) Dirty has the variable name '@s' (Uncommunicative Name)
        (masked) Dirty#a calls @s.title twice (Duplication)
        (masked) Dirty#a calls puts(@s.title) twice (Duplication)
        (masked) Dirty#a contains iterators nested 2 deep (Nested Iterators)
        (masked) Dirty#a has the name 'a' (Uncommunicative Name)
        (masked) Dirty#a has the variable name 'x' (Uncommunicative Name)

      """

    Examples:
      | options  |
      | -q -a    |
      | -a -q    |
