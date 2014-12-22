@masking
Feature: Masking smells using config files
  In order to keep my reports meaningful
  As a developer
  I want to mask some smells using config files

  Scenario: empty config file is ignored
    When I run reek -c spec/samples/empty_config_file/empty.reek spec/samples/empty_config_file/dirty.rb
    Then it reports the error 'Warning: Invalid configuration file "empty.reek" -- Empty file'
    And the exit status indicates smells
    And it reports:
      """
      spec/samples/empty_config_file/dirty.rb -- 6 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [4, 6]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
        [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
        [5]:Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      """

  Scenario: corrupt config file prevents normal output
    When I run reek -c spec/samples/corrupt_config_file/corrupt.reek spec/samples/corrupt_config_file
    Then it reports the error 'Error: Invalid configuration file "corrupt.reek" -- Not a hash'
    And the exit status indicates an error
    And it reports:
      """
      """

  Scenario: missing source file is an error
    When I run reek spec/samples/missing_source_file/dirty.rb
    Then it reports the error "Error: No such file - spec/samples/missing_source_file/dirty.rb"

  Scenario: switch off one smell
    When I run reek -c spec/samples/masked/masked.reek spec/samples/masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 3 warnings:
        [4, 6]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
      """

  Scenario: non-masked smells are only counted once
    When I run reek -c spec/samples/not_quite_masked/masked.reek spec/samples/not_quite_masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/not_quite_masked/dirty.rb -- 5 warnings:
        [5]:Dirty has the variable name '@s' (UncommunicativeVariableName)
        [4, 6]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
        [4, 6]:Dirty#a calls puts(@s.title) 2 times (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
        [3]:Dirty#a has the name 'a' (UncommunicativeMethodName)
      """

  Scenario: allow masking some calls for duplication smell
    When I run reek -c spec/samples/mask_some/some.reek spec/samples/mask_some/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/mask_some/dirty.rb -- 2 warnings:
        [4, 6]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
        [5]:Dirty#a contains iterators nested 2 deep (NestedIterators)
      """

  @comments
  Scenario: provide extra masking inline in comments
    When I run reek -c spec/samples/inline_config/masked.reek spec/samples/inline_config
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/inline_config/dirty.rb -- 1 warning:
        [5, 7]:Dirty#a calls @s.title 2 times (DuplicateMethodCall)
      """
