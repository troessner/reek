Feature: Basic smell detection
  In order to write better software
  As a developer
  I want to detect the smels in my Ruby code

  Scenario: Correct smells from inline.rb
    When I run reek spec/slow/samples/inline.rb
    Then it should fail with exit status 2
    And it should report:
    """
    "spec/slow/samples/inline.rb" -- 32 warnings:
      Inline::C has at least 13 instance variables (Large Class)
      Inline::C#build calls ($? == 0) multiple times (Duplication)
      Inline::C#build calls Inline.directory multiple times (Duplication)
      Inline::C#build calls io.puts multiple times (Duplication)
      Inline::C#build calls io.puts("#endif") multiple times (Duplication)
      Inline::C#build calls io.puts("#ifdef __cplusplus") multiple times (Duplication)
      Inline::C#build calls module_name multiple times (Duplication)
      Inline::C#build calls warn("Output:\n#{result}") multiple times (Duplication)
      Inline::C#build has approx 60 statements (Long Method)
      Inline::C#build has the variable name 't' (Uncommunicative Name)
      Inline::C#build/block/block has the variable name 'n' (Uncommunicative Name)
      Inline::C#build/block/block is nested (Nested Iterators)
      Inline::C#c has the name 'c' (Uncommunicative Name)
      Inline::C#crap_for_windoze calls Config::CONFIG["libdir"] multiple times (Duplication)
      Inline::C#generate calls result.sub!(/\A\n/, "") multiple times (Duplication)
      Inline::C#generate calls signature["args"] multiple times (Duplication)
      Inline::C#generate calls signature["args"].map multiple times (Duplication)
      Inline::C#generate has approx 32 statements (Long Method)
      Inline::C#initialize calls stack.empty? multiple times (Duplication)
      Inline::C#load calls so_name multiple times (Duplication)
      Inline::C#module_name/block has the variable name 'm' (Uncommunicative Name)
      Inline::C#module_name/block has the variable name 'x' (Uncommunicative Name)
      Inline::C#parse_signature has approx 15 statements (Long Method)
      Inline::C#parse_signature is controlled by argument raw (Control Couple)
      Inline::C#parse_signature/block has the variable name 'x' (Uncommunicative Name)
      Inline::C#strip_comments doesn't depend on instance state (Utility Function)
      Inline::C#strip_comments refers to src more than self (Feature Envy)
      Inline::self.rootdir calls env.nil? multiple times (Duplication)
      Inline::self.rootdir has approx 8 statements (Long Method)
      Module#inline calls Inline.const_get(lang) multiple times (Duplication)
      Module#inline has approx 11 statements (Long Method)
      Module#inline is controlled by argument options (Control Couple)

    """
