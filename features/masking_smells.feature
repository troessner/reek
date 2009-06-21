Feature: Masking smells using config files
  In order to keep my reports meaningful
  As a developer
  I want to mask some smells using config files

  Scenario: empty config file has no effect
    When I run reek spec/samples/empty_config_file/dirty.rb
    Then it fails with exit status 2
    And it reports:
      """
      "spec/samples/empty_config_file/dirty.rb" -- 6 warnings:
        Dirty has the variable name '@s' (Uncommunicative Name)
        Dirty#a calls @s.title multiple times (Duplication)
        Dirty#a calls puts(@s.title) multiple times (Duplication)
        Dirty#a has the name 'a' (Uncommunicative Name)
        Dirty#a/block has the variable name 'x' (Uncommunicative Name)
        Dirty#a/block/block is nested (Nested Iterators)

      """

  Scenario: switch off one smell
    When I run reek spec/samples/masked/dirty.rb
    Then it fails with exit status 2
    And it reports:
      """
      "spec/samples/masked/dirty.rb" -- 3 warnings:
        Dirty#a calls @s.title multiple times (Duplication)
        Dirty#a calls puts(@s.title) multiple times (Duplication)
        Dirty#a/block/block is nested (Nested Iterators)

      """
