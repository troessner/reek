Feature: Report smells using simple JSON layout
  In order to parse Reek's output simply and consistently, simply
  output a list of smells in JSON.

  Scenario: output is empty when there are no smells
    Given a directory called 'clean' containing two clean files
    When I run reek --format json clean
    Then it succeeds
    And it reports this JSON:
    """
    []
    """

  Scenario: Indicate smells and print them as JSON when using files
    Given the smelly file 'smelly.rb'
    When I run reek --format json smelly.rb
    Then the exit status indicates smells
    And it reports this JSON:
      """
      [
          {
              "smell_type": "UncommunicativeMethodName",
              "source": "smelly.rb",
              "context": "Smelly#x",
              "lines": [ 4 ],
              "message": "has the name 'x'",
              "documentation_link": {
                "html": "https://github.com/troessner/reek/blob/v5.3.1/docs/Uncommunicative-Method-Name.md",
                "markdown": "https://raw.githubusercontent.com/troessner/reek/v5.3.1/docs/Uncommunicative-Method-Name.md"
              },
              "name": "x"
          },
          {
              "smell_type": "UncommunicativeVariableName",
              "source": "smelly.rb",
              "context": "Smelly#x",
              "lines": [ 5 ],
              "message": "has the variable name 'y'",
              "documentation_link": {
                "html": "https://github.com/troessner/reek/blob/v5.3.1/docs/Uncommunicative-Variable-Name.md",
                "markdown": "https://raw.githubusercontent.com/troessner/reek/v5.3.1/docs/Uncommunicative-Variable-Name.md"
              },
              "name": "y"
          }
      ]
      """

  Scenario: Indicate smells and print them as JSON when using STDIN
    When I pass "class Turn; end" to reek --format json
    Then the exit status indicates smells
    And it reports this JSON:
      """
      [
          {
              "smell_type": "IrresponsibleModule",
              "source": "STDIN",
              "context": "Turn",
              "lines": [
                  1
              ],
              "message": "has no descriptive comment",
              "documentation_link": {
                "html": "https://github.com/troessner/reek/blob/v5.3.1/docs/Irresponsible-Module.md",
                "markdown": "https://raw.githubusercontent.com/troessner/reek/v5.3.1/docs/Irresponsible-Module.md"
              }        
          }
      ]
      """
