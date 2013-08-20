@masking
Feature: Masking smells using config files
  In order to keep my reports meaningful
  As a developer
  I want to mask some smells using config files

  Scenario: empty config file is ignored
    When I run reek spec/samples/empty_config_file/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/empty_config_file/dirty.rb -- 6 warnings:
        Dirty has the variable name '@s' (UncommunicativeVariableName)
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
        Dirty#a has the name 'a' (UncommunicativeMethodName)
        Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      """

  Scenario: corrupt config file prevents normal output
    When I run reek spec/samples/corrupt_config_file
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/corrupt_config_file/dirty.rb -- 7 warnings:
        Dirty has no descriptive comment (IrresponsibleModule)
        Dirty has the variable name '@s' (UncommunicativeVariableName)
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
        Dirty#a has the name 'a' (UncommunicativeMethodName)
        Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      """
    And it reports an error

  Scenario: missing source file is an error
    When I run reek no_such_file.rb spec/samples/masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 3 warnings:
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
      """
    And it reports the error "Error: No such file - no_such_file.rb"

  Scenario: switch off one smell
    When I run reek spec/samples/masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 3 warnings:
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
      """

  Scenario: non-masked smells are only counted once
    When I run reek spec/samples/not_quite_masked/dirty.rb
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

  @overrides
  Scenario: lower overrides upper
    When I run reek spec/samples/overrides
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/overrides/masked/dirty.rb -- 2 warnings:
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
      """

  Scenario: allow masking some calls for duplication smell
    When I run reek spec/samples/mask_some/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/mask_some/dirty.rb -- 2 warnings:
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
      """

  @comments
  Scenario: provide extra masking inline in comments
    When I run reek spec/samples/inline_config
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/inline_config/dirty.rb -- 1 warning:
        Dirty#a calls @s.title twice (DuplicateMethodCall)
      """

  Scenario: supports a config file
    When I run reek -c spec/samples/config/allow_duplication.reek spec/samples/masked/dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 1 warning:
        Dirty#a contains iterators nested 2 deep (NestedIterators)
      """

  Scenario: supports multiple config files
    When I run reek -c spec/samples/config/allow_duplication.reek -c spec/samples/config/deeper_nested_iterators.reek spec/samples/masked/dirty.rb
    Then it succeeds
    And it reports:
      """
      spec/samples/masked/dirty.rb -- 0 warnings
      """
