Feature: Validate schema
  In order to ensure that I am using the right configuration
  As a user
  I want to be notified when I am using a configuration that violates our schema

  Scenario: Our generated default configuration
    Given our default configuration file
    And the clean file "clean.rb"
    When I run reek -c defaults.reek clean.rb
    Then it succeeds
    And it reports nothing

  Scenario: Detectors, directories and exclude paths all mixed
    Given a file named "config.reek" with:
    """
    ---
    detectors:
      IrresponsibleModule:
        enabled: false
      NestedIterators:
        exclude:
          - "MyWorker#self.class_method"
          - "AnotherWorker#instance_method"
      DataClump:
        max_copies: 3
        min_clump_size: 3

    directories:
      "web_app/app/controllers":
        NestedIterators:
          enabled: false
      "web_app/app/helpers":
        UtilityFunction:
          enabled: false

    exclude_paths:
      - lib/legacy
    """
    And a directory named "lib/legacy"
    And the clean file "clean.rb"
    When I run reek -c config.reek clean.rb
    Then it succeeds
    And it reports nothing

  Scenario: Invalid detector name
    Given a file named "config.reek" with:
    """
    ---
    detectors:
      DoesNotExist:
        enabled: true
    """
    And the clean file "clean.rb"
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: We found some problems with your configuration file: [/detectors/DoesNotExist] key 'DoesNotExist:' is undefined.
    """
