@profile
Feature: Reek's configuration can be based on any number of canned profiles
  The starting point for configuring the smell detectors can be
  selected from a list of supplied config files.

  Scenario: XP profile reveals Attribute smells
    When I run reek --profile xp spec/samples/not_quite_masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/not_quite_masked/dirty.rb -- 5 warnings (+2 masked):
        Dirty declares the attribute property (Attribute)
        Dirty has the variable name '@s' (Uncommunicative Name)
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a has the name 'a' (Uncommunicative Name)

      """

  Scenario: XP profile works with unmasked smells
    When I run reek --show-all --profile xp spec/samples/not_quite_masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/not_quite_masked/dirty.rb -- 5 warnings (+2 masked):
        Dirty declares the attribute property (Attribute)
        Dirty has the variable name '@s' (Uncommunicative Name)
        Dirty#a calls @s.title twice (Duplication)
        Dirty#a calls puts(@s.title) twice (Duplication)
        Dirty#a has the name 'a' (Uncommunicative Name)
        (masked) Dirty#a/block has the variable name 'x' (Uncommunicative Name)
        (masked) Dirty#a/block/block is nested (Nested Iterators)

      """
