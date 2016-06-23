Feature: Smell - SubclassedFromCoreClass
  Scenario: Reports smell
    Given a file named "my_hash.rb" with:
      """
      # The MyHash class
      class MyHash < Hash
      end
      """
    When I run `reek my_hash.rb`
    Then it reports:
    """
    my_hash.rb -- 1 warning:
      [2]:SubclassedFromCoreClass: MyHash inherits from a core class (Hash) [https://github.com/troessner/reek/blob/master/docs/Subclassed-From-Core-Class.md]
    """
