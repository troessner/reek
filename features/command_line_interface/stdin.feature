Feature: Reek reads from $stdin when no files are given
  In order to use reek with pipelines
  As a developer
  I want to pipe source code on stdin

  Scenario: return zero status with no smells
    When I pass "def simple() @fred = 3 end" to reek
    Then it succeeds
    And it reports nothing

  Scenario: outputs nothing on empty stdin
    When I pass "" to reek
    Then it succeeds
    And it reports nothing

  Scenario: outputs header only on empty stdin in verbose mode
    When I pass "" to reek -V
    Then it succeeds
    And it reports:
      """
      STDIN -- 0 warnings
      """

  Scenario: return non-zero status when there are smells
    When I pass "class Turn; def y() @x = 3; end end" to reek
    Then the exit status indicates smells
    And it reports:
      """
      STDIN -- 3 warnings:
        [1]:IrresponsibleModule: Turn has no descriptive comment
        [1]:UncommunicativeMethodName: Turn#y has the name 'y'
        [1]:UncommunicativeVariableName: Turn has the variable name '@x'
      """

  Scenario: syntax error causes the source to be ignored
    When I pass "= invalid syntax =" to reek
    Then it succeeds
    And it reports the error "Parser::SyntaxError: unexpected token tEQL"

  Scenario: providing a filename to use for the config to match against
    Given a file named "web_app/config.reek" with:
      """
      ---
      directories:
        "web_app/app/controllers":
          IrresponsibleModule:
            enabled: false
          NestedIterators:
            enabled: false
          InstanceVariableAssumption:
            enabled: false
      """
    When I pass a stdin to reek --config web_app/config.reek --stdin-filename web_app/app/controllers/users_controller with:
      """
      class UsersController < ApplicationController
        def show
          respond_with do |format|
            format.json { |json| @user.to_custom_json }
            format.xml { |xml| @user.to_fancy_xml }
          end
        end
      end
      """
    Then it succeeds
    And it reports nothing
