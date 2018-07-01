Feature: Show configuration file
  With Reeks dynamic mechanism of finding a configuration file you might run into a situation where you are not
  100% sure what configuration file Reek is using. E.g. you have a project specific configuration file in your
  project root and also another Reek configuration in your HOME directory that you use for all your other projects
  and for whatever reasons Reek seems to be using another configuration file than the one you assumed it would.
  In this case you can pass the flag `--show-configuration-path` to Reek which will cause Reek to output the path
  to the configuration file it is using.

  Scenario: Default configuration file present
    Given the clean file "clean.rb"
    And an empty file named ".reek.yml"
    When I run reek --show-configuration-path clean.rb
    Then it reports:
      """
      Using '.reek.yml' as configuration file.
      """

  Scenario: Non-default configuration file passed via CLI
    Given the clean file "clean.rb"
    And an empty file named "config.reek"
    When I run reek --show-configuration-path -c config.reek clean.rb
    Then it reports:
      """
      Using 'config.reek' as configuration file.
      """

  Scenario: Display the right configuration file even when there are multiple files present
    Given the clean file "clean.rb"
    And an empty file named ".reek.yml"
    And an empty file named "config.reek"
    When I run reek --show-configuration-path -c config.reek clean.rb
    Then it reports:
      """
      Using 'config.reek' as configuration file.
      """

  Scenario: Use configuration file we find when traversing up the directory tree
    Given the clean file "clean.rb"
    And with a configuration file that is further up in the directory tree
    When I run reek --show-configuration-path clean.rb
    Then it reports:
      """
      Using '../../.reek.yml' as configuration file.
      """
