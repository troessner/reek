Feature: Reek can be controlled using command-line options
  In order to change Reek's default behaviour
  As a developer
  I want to supply options on the command line

  Scenario: return non-zero status on bad option
    When I run reek --no-such-option
    Then the exit status indicates an error
    And it reports the error "Error: invalid option: --no-such-option"
    And there is no output on stdout

  Scenario: display the current version number
    When I run reek --version
    Then it succeeds
    And it reports the current version

  Scenario: return given status code when using --failure-exit-code
    Given the smelly file 'smelly.rb'
    When I run reek smelly.rb --failure-exit-code 23
    Then the exit status is 23

  Scenario: return given status code when using --success-exit-code
    Given the clean file "clean.rb"
    When I run reek clean.rb --success-exit-code 42
    Then the exit status is 42

  Scenario: display the help information
    When I run reek --help
    Then it succeeds
    And it reports:
      """
      Usage: reek [options] [files]

      Examples:

      reek lib/*.rb
      reek -s lib
      cat my_class.rb | reek

      See https://github.com/troessner/reek for detailed help.

      Configuration:
          -c, --config FILE                Read configuration options from FILE
              --smell SMELL                Only look for a specific smell.
                                           Call it like this: reek --smell MissingSafeMethod source.rb
                                           Check out https://github.com/troessner/reek/blob/v5.6.0/docs/Code-Smells.md for a list of smells
              --stdin-filename FILE        When passing code in via pipe, assume this filename when checking file or directory rules in the config.

      Generate a todo list:
          -t, --todo                       Generate a todo list

      Report format:
          -f, --format FORMAT              Report smells in the given format:
                                             html
                                             text (default)
                                             yaml
                                             json
                                             xml
                                             code_climate

      Text format options:
              --[no-]color                 Use colors for the output (default: true)
          -V, --[no-]empty-headings        Show headings for smell-free source files (default: false)
          -U, --[no-]documentation         Show link to related documentation page for each smell (default: true)
              --[no-]show-configuration-path
                                           Show which configuration file Reek is using (default: false)
          -n, --[no-]line-numbers          Show line numbers in the output (default: true)
          -s, --single-line                Show location in editor-compatible single-line-per-smell format
          -P, --[no-]progress              Show progress of each source as it is examined (default: true)
              --sort-by SORTING            Sort reported files by the given criterium:
                                             smelliness ("smelliest" files first)
                                             none (default - output in processing order)
              --force-exclusion            Force excluding files specified in the configuration `exclude_paths`
                                             even if they are explicitly passed as arguments

     Exit codes:
              --success-exit-code CODE     The exit code when no smells are found (default: 0)
              --failure-exit-code CODE     The exit code when smells are found (default: 2)

      Utility options:
          -h, --help                       Show this message
          -l, --list                       List all available smell detectors
          -v, --version                    Show version
      """

  Scenario: List all available smell detectors
    When I run reek --list
    Then it succeeds
    And it reports:
      """
      All available smell detectors:

      Attribute
      BooleanParameter
      ClassVariable
      ControlParameter
      DataClump
      DuplicateMethodCall
      FeatureEnvy
      InstanceVariableAssumption
      IrresponsibleModule
      LongParameterList
      LongYieldList
      ManualDispatch
      MissingSafeMethod
      ModuleInitialize
      NestedIterators
      NilCheck
      RepeatedConditional
      SubclassedFromCoreClass
      TooManyConstants
      TooManyInstanceVariables
      TooManyMethods
      TooManyStatements
      UncommunicativeMethodName
      UncommunicativeModuleName
      UncommunicativeParameterName
      UncommunicativeVariableName
      UnusedParameters
      UnusedPrivateMethod
      UtilityFunction

      Check out https://github.com/troessner/reek/blob/v5.6.0/docs/Code-Smells.md for a details on each detector
      """
