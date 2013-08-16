@smells_count
Feature: Reports total number of code smells
	In order to monitor the total number of smells
	Reek outputs the total number of smells among all files inspected.

	Scenario: Does not output total number of smells when inspecting single file
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

  Scenario: Output total number of smells when inspecting multiple files
  	When I run reek spec/samples/two_smelly_files
  	Then the exit status indicates smells
    And it reports:
      """
      spec/samples/two_smelly_files/dirty_one.rb -- 6 warnings:
        Dirty has the variable name '@s' (UncommunicativeVariableName)
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
        Dirty#a has the name 'a' (UncommunicativeMethodName)
        Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      spec/samples/two_smelly_files/dirty_two.rb -- 6 warnings:
        Dirty has the variable name '@s' (UncommunicativeVariableName)
        Dirty#a calls @s.title twice (DuplicateMethodCall)
        Dirty#a calls puts(@s.title) twice (DuplicateMethodCall)
        Dirty#a contains iterators nested 2 deep (NestedIterators)
        Dirty#a has the name 'a' (UncommunicativeMethodName)
        Dirty#a has the variable name 'x' (UncommunicativeVariableName)
      12 total warnings
      """

  Scenario: Output total number of smells even if total equals 0
  	When I run reek spec/samples/three_clean_files
  	Then it succeeds
    And it reports:
      """
      spec/samples/three_clean_files/clean_one.rb -- 0 warnings
      spec/samples/three_clean_files/clean_three.rb -- 0 warnings
      spec/samples/three_clean_files/clean_two.rb -- 0 warnings
      0 total warning
      """