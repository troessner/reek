Feature: Validate schema
  In order to ensure that I am using the right configuration
  As a user
  I want to be notified when I am using a configuration that violates our schema

  Scenario: Our generated default configuration
    Given our default configuration file 'defaults.reek'
    And the clean file 'clean.rb'
    When I run reek -c defaults.reek clean.rb
    Then it succeeds
    And it reports nothing

  Scenario: Invalid detector name
    Given a file named "config.reek" with:
    """
    ---
    DoesNotExist:
      enabled: true
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: Hash had extra keys: ["DoesNotExist"] (/rec)
    """

  Scenario: enabled has a non-boolean value
    Given a file named "config.reek" with:
    """
    ---
    FeatureEnvy:
      enabled: "foo"
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected bool got "foo" (/rec:'FeatureEnvy')
    """

  Scenario: `exclude` is a scalar
    Given a file named "config.reek" with:
    """
    ---
    FeatureEnvy:
      exclude: "foo"
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected array got String (/rec:'FeatureEnvy')
    """

  Scenario: `exclude` mixes types
    Given a file named "config.reek" with:
    """
    ---
    FeatureEnvy:
      exclude:
        - true
        - "foo"
        - 42
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected String got true (/rec:'FeatureEnvy')
    """

  Scenario: Detector has an unknown option
    Given a file named "config.reek" with:
    """
    ---
    DataClump:
      does_not_exist: "foo"
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: Hash had extra keys: ["does_not_exist"] (/rec:'DataClump')
    """

  Scenario: `reject` is a scalar
    Given a file named "config.reek" with:
    """
    ---
    UncommunicativeMethodName:
      reject: "foo"
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected array got String (/rec:'UncommunicativeMethodName')
    """

  Scenario: `reject` mixes types
    Given a file named "config.reek" with:
    """
    ---
    UncommunicativeMethodName:
      reject:
        - true
        - "foo"
        - 42
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected String got true (/rec:'UncommunicativeMethodName')
    """

  Scenario: `accept` is a scalar
    Given a file named "config.reek" with:
    """
    ---
    UncommunicativeMethodName:
      accept: "foo"
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected array got String (/rec:'UncommunicativeMethodName')
    """

  Scenario: `accept` mixes types
    Given a file named "config.reek" with:
    """
    ---
    UncommunicativeMethodName:
      accept:
        - true
        - "foo"
        - 42
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected String got true (/rec:'UncommunicativeMethodName')
    """

  Scenario: `exclude_paths` is a scalar
    Given a file named "config.reek" with:
    """
    ---
    exclude_paths: "foo"
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected array got String (/rec:'exclude_paths')
    """

  Scenario: `exclude_paths` mixes types
    Given a file named "config.reek" with:
    """
    ---
    exclude_paths:
      - true
      - "foo"
      - 42
    """
    And the clean file 'clean.rb'
    When I run reek -c config.reek clean.rb
    Then the exit status indicates an error
    And stderr reports:
    """
    Error: Invalid configuration file: expected String got true (/rec:'exclude_paths')
    """

  Scenario: directories
