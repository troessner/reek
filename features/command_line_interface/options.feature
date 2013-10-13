@options
Feature: Reek can be controlled using command-line options
  In order to change reek's default behaviour
  As a developer
  I want to supply options on the command line

  Scenario: return non-zero status on bad option
    When I run reek --no-such-option
    Then the exit status indicates an error
    And it reports the error "Error: invalid option: --no-such-option"
    And stdout equals ""

  Scenario: display the current version number
    When I run reek --version
    Then it succeeds
    And it reports the current version

  Scenario: display the help information
    When I run reek --help
    Then it succeeds
    And it reports:
      """
      Usage: reek [options] [files]

      Examples:

      reek lib/*.rb
      reek -q lib
      cat my_class.rb | reek

      See http://wiki.github.com/troessner/reek for detailed help.

      Common options:
          -h, --help                       Show this message
          -v, --version                    Show version

      Configuration:
          -c, --config FILE                Read configuration options from FILE

      Report formatting:
          -q, --[no-]quiet                 Suppress headings for smell-free source files
          -n, --line-number                Suppress line number(s) from the output.
          -s, --single-line                Show IDE-compatible single-line-per-warning
          -y, --yaml                       Report smells in YAML format

      """
