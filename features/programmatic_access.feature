Feature: Using Reek programmatically
  In order to use Reek from inside my program
  As a developer
  I want to be able to use its classes

  Scenario: Accessing smells found by an examiner
    Given a smelly file called 'smelly.rb'
    And a file named "examine.rb" with:
      """
      require 'reek'
      examiner = Reek::Examiner.new(File.new('smelly.rb'))
      examiner.smells.each do |smell|
        puts smell.message
      end
      """
    When I run `ruby examine.rb`
    Then it reports no errors
    And it reports:
      """
      calls @foo.bar 2 times
      calls puts(@foo.bar) 2 times
      has the name 'm'
      """

  Scenario: Using Reek's built-in report classes
    Given a smelly file called 'smelly.rb'
    And a file named "examine.rb" with:
      """
      require 'reek'
      examiner = Reek::Examiner.new(File.new('smelly.rb'))
      report = Reek::Report::TextReport.new
      report.add_examiner examiner
      report.show
      """
    When I run `ruby examine.rb`
    Then it reports no errors
    And it reports:
      """
      smelly.rb -- 3 warnings:
        Smelly#m calls @foo.bar 2 times (DuplicateMethodCall)
        Smelly#m calls puts(@foo.bar) 2 times (DuplicateMethodCall)
        Smelly#m has the name 'm' (UncommunicativeMethodName)
      """
