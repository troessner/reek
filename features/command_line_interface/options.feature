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
              --smell SMELL                Detect smell SMELL (default is all enabled smells)

      Report formatting:
          -o, --[no-]color                 Use colors for the output (this is the default)
          -q, --quiet                      Suppress headings for smell-free source files (this is the default)
          -V, --no-quiet, --verbose        Show headings for smell-free source files
          -U, --ultra-verbose              Be as explanatory as possible
          -n, --no-line-numbers            Suppress line numbers from the output
              --line-numbers               Show line numbers in the output (this is the default)
          -s, --single-line                Show IDE-compatible single-line-per-warning
          -S, --sort-by-issue-count        Sort by "issue-count", listing the "smelliest" files first
          -y, --yaml                       Report smells in YAML format
          -H, --html                       Report smells in HTML format

      """
