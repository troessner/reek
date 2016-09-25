Feature: Smell - TooManyConstants
  Scenario: Reports smell
    Given a file named "my_class.rb" with:
      """
      class MyClass
        A = 1
        B = 2
        C = 3
        D = 4
        E = 5
        F = 6
      end
      """
    When I run `reek my_class.rb`
    Then it reports:
    """
    Inspecting 1 file(s):
    S

    my_class.rb -- 1 warning:
      [1]:TooManyConstants: MyClass has 6 constants [https://github.com/troessner/reek/blob/master/docs/Too-Many-Constants.md]
    """
