Feature: Smell - SubclassedFromCoreClass
  Scenario: Configure multiple directories
    Given a file named "web_app/config.reek" with:
      """
      ---
      "web_app/app/models":
        IrresponsibleModule:
          enabled: false
      """
    And a file named "web_app/app/models/my_hash.rb" with:
      """
      class MyHash < Hash
      end
      """
    When I run `reek -c web_app/config.reek web_app/`
    Then it reports:
    """
    web_app/app/models/my_hash.rb -- 1 warning:
      [1]:SubclassedFromCoreClass: MyHash inherits from a core class Hash [https://github.com/troessner/reek/blob/master/docs/Subclassed-From-Core-Class.md]
    """
