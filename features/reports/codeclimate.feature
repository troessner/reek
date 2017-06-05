Feature: Report smells using Code Climate format
  In order to run as an Engine on Code Climate, output format following their
  spec.

  Scenario: output is empty when there are no smells
    Given a directory called 'clean' containing two clean files
    When I run reek --format code_climate clean
    Then it succeeds
    And it reports this Code Climate output:
    """
    """

  Scenario: Indicate smells and print them as JSON when using files
    Given the smelly file 'smelly.rb'
    When I run reek --format code_climate smelly.rb
    Then it reports this Code Climate output:
      """
      {
        "type": "issue",
        "check_name": "UncommunicativeMethodName",
        "description": "Smelly#x has the name 'x'",
        "categories": [
          "Complexity"
        ],
        "location": {
          "path": "smelly.rb",
          "lines": {
            "begin": 4,
            "end": 4
          }
        },
        "remediation_points": 150000,
        "content": {
          "body": "An `Uncommunicative Method Name` is a method name that doesn't communicate its intent well enough.\n\nPoor names make it hard for the reader to build a mental picture of what's going on in the code. They can also be mis-interpreted; and they hurt the flow of reading, because the reader must slow down to interpret the names.\n"
        },
        "fingerprint": "2b41a3a4bb7de31ac4f5944bf68b7f5f"
      }
      NULL_BYTE_CHARACTER
      {
        "type": "issue",
        "check_name": "UncommunicativeVariableName",
        "description": "Smelly#x has the variable name 'y'",
        "categories": [
          "Complexity"
        ],
        "location": {
          "path": "smelly.rb",
          "lines": {
            "begin": 5,
            "end": 5
          }
        },
        "remediation_points": 150000,
        "content": {
          "body": "An `Uncommunicative Variable Name` is a variable name that doesn't communicate its intent well enough.\n\nPoor names make it hard for the reader to build a mental picture of what's going on in the code. They can also be mis-interpreted; and they hurt the flow of reading, because the reader must slow down to interpret the names.\n"
        },
        "fingerprint": "72f0dc8f8da5f9d7b8b29318636e5609"
      }
      """
