Feature: Offer different ways how to load configuration

  There are 3 ways of passing reek a configuration file:
  - Using the cli "-c" switch
  - Having a file ending with .reek either in your current working directory or in a parent directory
  - Having a file ending with .reek in your HOME directory
  The order in which reek tries to find such a configuration file should exactly be like above:
  First reek should check if we have given it a configuration file explicitly via CLI.
  Then it should check the current working directory for a file and if it can't find one,
  it should traverse up the directories until it hits the root directory.
  And finally, it should check your HOME directory.

  Scenario: No configuration
    When I run reek spec/samples/configuration_loading/minimal_dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/configuration_loading/minimal_dirty.rb -- 3 warnings:
        [1]:C has no descriptive comment (IrresponsibleModule)
        [1]:C has the name 'C' (UncommunicativeModuleName)
        [2]:C#m has the name 'm' (UncommunicativeMethodName)
      """

  Scenario: Configuration via CLI
    When I run reek -c spec/samples/minimal_smelly_and_masked/config.reek spec/samples/minimal_smelly_and_masked/minimal_dirty.rb
    Then it reports no errors
    And it succeeds

  @remove-disable-smell-config-from-current-dir
  Scenario: Configuration file in working directory
    Given "spec/samples/configuration_loading/reek-test-run-disable_smells.reek" exists in the working directory
    When I run reek spec/samples/configuration_loading/minimal_dirty.rb
    Then it reports no errors
    And it succeeds

  @remove-disable-smell-config-from-parent-dir
  Scenario: Configuration file in the parent directory of the working directory
    Given "spec/samples/configuration_loading/reek-test-run-disable_smells.reek" exists in the parent directory of the working directory
    When I run reek spec/samples/configuration_loading/minimal_dirty.rb
    Then it reports no errors
    And it succeeds

  @remove-disable-smell-config-from-home-dir
  Scenario: Configuration file in the HOME directory
    Given "spec/samples/configuration_loading/reek-test-run-disable_smells.reek" exists in the HOME directory
    When I run reek spec/samples/configuration_loading/minimal_dirty.rb
    Then it reports no errors
    And it succeeds

  @remove-enable-smell-config-from-current-dir @remove-disable-smell-config-from-parent-dir
  Scenario: Two opposing configuration files and we stop after the first one
    Given "spec/samples/configuration_loading/reek-test-run-enable_smells.reek" exists in the working directory
    And "spec/samples/configuration_loading/reek-test-run-disable_smells.reek" exists in the parent directory of the working directory
    When I run reek spec/samples/configuration_loading/minimal_dirty.rb
    Then the exit status indicates smells
    And it reports:
      """
      spec/samples/configuration_loading/minimal_dirty.rb -- 3 warnings:
        [1]:C has no descriptive comment (IrresponsibleModule)
        [1]:C has the name 'C' (UncommunicativeModuleName)
        [2]:C#m has the name 'm' (UncommunicativeMethodName)
      """
