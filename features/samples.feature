Feature: Basic smell detection
  In order to write better software
  As a developer
  I want to detect the smells in my Ruby code

  Scenario: Correct smells from inline.rb
    Given the smelly file 'inline.rb'
    And the smelly file 'optparse.rb'
    And the smelly file 'redcloth.rb'
    When I run reek --no-line-numbers inline.rb optparse.rb redcloth.rb
    Then the exit status indicates smells
    And it reports:
    """
    inline.rb -- 51 warnings:
      BooleanParameter: Inline::C#parse_signature has boolean parameter 'raw'
      ClassVariable: Inline declares the class variable '@@directory'
      ClassVariable: Inline declares the class variable '@@rootdir'
      ClassVariable: Inline::C declares the class variable '@@type_map'
      ControlParameter: Inline::C#parse_signature is controlled by argument 'raw'
      DataClump: Inline::C takes parameters ['options', 'src'] to 5 methods
      DuplicateMethodCall: Inline#self.rootdir calls 'env.nil?' 2 times
      DuplicateMethodCall: Inline::C#build calls '$? != 0' 2 times
      DuplicateMethodCall: Inline::C#build calls 'Inline.directory' 5 times
      DuplicateMethodCall: Inline::C#build calls 'io.puts "#endif"' 2 times
      DuplicateMethodCall: Inline::C#build calls 'io.puts "#ifdef __cplusplus"' 2 times
      DuplicateMethodCall: Inline::C#build calls 'io.puts' 6 times
      DuplicateMethodCall: Inline::C#build calls 'warn "Output:\n#{result}"' 2 times
      DuplicateMethodCall: Inline::C#crap_for_windoze calls 'Config::CONFIG['libdir']' 2 times
      DuplicateMethodCall: Inline::C#generate calls 'result.sub!(/\A\n/, '')' 2 times
      DuplicateMethodCall: Inline::C#generate calls 'signature['args']' 2 times
      DuplicateMethodCall: Inline::C#generate calls 'signature['args'].map' 2 times
      DuplicateMethodCall: Inline::C#initialize calls 'stack.empty?' 2 times
      DuplicateMethodCall: Module#inline calls 'Inline.const_get(lang)' 2 times
      DuplicateMethodCall: Module#inline calls 'options[:testing]' 2 times
      InstanceVariableAssumption: Inline::C assumes too much for instance variable '@module_name'
      InstanceVariableAssumption: Inline::C assumes too much for instance variable '@so_name'
      InstanceVariableAssumption: Inline::C assumes too much for instance variable '@types'
      IrresponsibleModule: CompilationError has no descriptive comment
      IrresponsibleModule: Dir has no descriptive comment
      IrresponsibleModule: File has no descriptive comment
      IrresponsibleModule: Module has no descriptive comment
      NestedIterators: Inline::C#build contains iterators nested 2 deep
      NilCheck: Inline#self.rootdir performs a nil-check
      RepeatedConditional: Inline::C tests '$DEBUG' at least 7 times
      RepeatedConditional: Inline::C tests '$TESTING' at least 4 times
      RepeatedConditional: Inline::C tests '@@type_map.has_key? type' at least 3 times
      TooManyConstants: Inline has 6 constants
      TooManyInstanceVariables: Inline::C has at least 13 instance variables
      TooManyMethods: Inline::C has at least 25 methods
      TooManyStatements: File#self.write_with_backup has approx 6 statements
      TooManyStatements: Inline#self.rootdir has approx 8 statements
      TooManyStatements: Inline::C#build has approx 63 statements
      TooManyStatements: Inline::C#generate has approx 35 statements
      TooManyStatements: Inline::C#module_name has approx 7 statements
      TooManyStatements: Inline::C#parse_signature has approx 16 statements
      TooManyStatements: Module#inline has approx 12 statements
      UncommunicativeMethodName: Inline::C#c has the name 'c'
      UncommunicativeModuleName: Inline::C has the name 'C'
      UncommunicativeVariableName: Inline::C#build has the variable name 'n'
      UncommunicativeVariableName: Inline::C#build has the variable name 't'
      UncommunicativeVariableName: Inline::C#module_name has the variable name 'm'
      UncommunicativeVariableName: Inline::C#module_name has the variable name 'md5'
      UncommunicativeVariableName: Inline::C#module_name has the variable name 'x'
      UncommunicativeVariableName: Inline::C#parse_signature has the variable name 'x'
      UtilityFunction: Inline::C#strip_comments doesn't depend on instance state (maybe move it to another class?)
    optparse.rb -- 126 warnings:
      Attribute: OptionParser#banner is a writable attribute
      Attribute: OptionParser#default_argv is a writable attribute
      Attribute: OptionParser#program_name is a writable attribute
      Attribute: OptionParser#release is a writable attribute
      Attribute: OptionParser#summary_indent is a writable attribute
      Attribute: OptionParser#summary_width is a writable attribute
      Attribute: OptionParser#version is a writable attribute
      Attribute: OptionParser::ParseError#reason is a writable attribute
      BooleanParameter: OptionParser#complete has boolean parameter 'icase'
      BooleanParameter: OptionParser::Completion#complete has boolean parameter 'icase'
      BooleanParameter: OptionParser::List#complete has boolean parameter 'icase'
      ControlParameter: OptionParser#summarize is controlled by argument 'blk'
      ControlParameter: OptionParser::Arguable#options= is controlled by argument 'opt'
      ControlParameter: OptionParser::ParseError#set_option is controlled by argument 'eq'
      DuplicateMethodCall: OptionParser#getopts calls 'result[opt] = false' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'default_style.guess(arg = a)' 4 times
      DuplicateMethodCall: OptionParser#make_switch calls 'long << (o = q.downcase)' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'notwice(NilClass, klass, 'type')' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'notwice(a ? Object : TrueClass, klass, 'type')' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'pattern.method(:convert)' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'pattern.method(:convert).to_proc' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'pattern.respond_to?(:convert)' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'q.downcase' 3 times
      DuplicateMethodCall: OptionParser#make_switch calls 'sdesc << "-#{q}"' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'search(:atype, FalseClass)' 2 times
      DuplicateMethodCall: OptionParser#make_switch calls 'search(:atype, o)' 6 times
      DuplicateMethodCall: OptionParser#order calls 'argv[0]' 2 times
      DuplicateMethodCall: OptionParser#parse calls 'argv[0]' 2 times
      DuplicateMethodCall: OptionParser#parse_in_order calls '$!.set_option(arg, true)' 2 times
      DuplicateMethodCall: OptionParser#parse_in_order calls 'cb.call(val)' 2 times
      DuplicateMethodCall: OptionParser#parse_in_order calls 'raise $!.set_option(arg, true)' 2 times
      DuplicateMethodCall: OptionParser#parse_in_order calls 'raise(*exc)' 2 times
      DuplicateMethodCall: OptionParser#parse_in_order calls 'setter.call(sw.switch_name, val)' 2 times
      DuplicateMethodCall: OptionParser#parse_in_order calls 'sw.block' 2 times
      DuplicateMethodCall: OptionParser#parse_in_order calls 'sw.switch_name' 2 times
      DuplicateMethodCall: OptionParser#permute calls 'argv[0]' 2 times
      DuplicateMethodCall: OptionParser::Completion#complete calls 'candidates.size' 2 times
      DuplicateMethodCall: OptionParser::Completion#complete calls 'k.id2name' 2 times
      DuplicateMethodCall: OptionParser::Switch#parse_arg calls 's.length' 2 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 'indent + l' 2 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 'left.collect {|s| s.length}' 2 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 'left.collect {|s| s.length}.max' 2 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 'left.collect {|s| s.length}.max.to_i' 2 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 'left.collect' 2 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 'left.shift' 2 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 'left[-1]' 3 times
      DuplicateMethodCall: OptionParser::Switch#summarize calls 's.length' 3 times
      FeatureEnvy: OptionParser#order refers to 'argv' more than self (maybe move it to another class?)
      FeatureEnvy: OptionParser#parse refers to 'argv' more than self (maybe move it to another class?)
      FeatureEnvy: OptionParser#permute refers to 'argv' more than self (maybe move it to another class?)
      FeatureEnvy: OptionParser::Completion#complete refers to 'candidates' more than self (maybe move it to another class?)
      FeatureEnvy: OptionParser::List#accept refers to 'pat' more than self (maybe move it to another class?)
      FeatureEnvy: OptionParser::List#add_banner refers to 'opt' more than self (maybe move it to another class?)
      FeatureEnvy: OptionParser::List#summarize refers to 'opt' more than self (maybe move it to another class?)
      InstanceVariableAssumption: OptionParser assumes too much for instance variable '@release'
      InstanceVariableAssumption: OptionParser assumes too much for instance variable '@version'
      LongParameterList: OptionParser#complete has 4 parameters
      LongParameterList: OptionParser#summarize has 4 parameters
      LongParameterList: OptionParser::List#complete has 4 parameters
      LongParameterList: OptionParser::List#update has 5 parameters
      LongParameterList: OptionParser::Switch#initialize has 7 parameters
      LongParameterList: OptionParser::Switch#summarize has 5 parameters
      ManualDispatch: OptionParser#make_switch manually dispatches method call
      ManualDispatch: OptionParser::List#accept manually dispatches method call
      ManualDispatch: OptionParser::List#add_banner manually dispatches method call
      ManualDispatch: OptionParser::List#summarize manually dispatches method call
      ModuleInitialize: OptionParser::Arguable has initialize method
      NestedIterators: OptionParser#make_switch contains iterators nested 2 deep
      NilCheck: OptionParser#make_switch performs a nil-check
      NilCheck: OptionParser#self.inc performs a nil-check
      RepeatedConditional: OptionParser tests 'a' at least 7 times
      RepeatedConditional: OptionParser tests 'argv.size == 1 and Array === argv[0]' at least 3 times
      RepeatedConditional: OptionParser tests 'default_pattern' at least 7 times
      RepeatedConditional: OptionParser tests 'not_style' at least 3 times
      RepeatedConditional: OptionParser tests 's' at least 7 times
      SubclassedFromCoreClass: OptionParser::CompletingHash inherits from core class 'Hash'
      SubclassedFromCoreClass: OptionParser::OptionMap inherits from core class 'Hash'
      TooManyConstants: OptionParser has 16 constants
      TooManyInstanceVariables: OptionParser has at least 6 instance variables
      TooManyInstanceVariables: OptionParser::Switch has at least 7 instance variables
      TooManyMethods: OptionParser has at least 42 methods
      TooManyStatements: OptionParser#complete has approx 6 statements
      TooManyStatements: OptionParser#getopts has approx 18 statements
      TooManyStatements: OptionParser#load has approx 6 statements
      TooManyStatements: OptionParser#make_switch has approx 72 statements
      TooManyStatements: OptionParser#parse_in_order has approx 35 statements
      TooManyStatements: OptionParser#permute! has approx 6 statements
      TooManyStatements: OptionParser::Arguable#options has approx 6 statements
      TooManyStatements: OptionParser::Completion#complete has approx 23 statements
      TooManyStatements: OptionParser::List#update has approx 10 statements
      TooManyStatements: OptionParser::Switch#parse_arg has approx 11 statements
      TooManyStatements: OptionParser::Switch#self.guess has approx 6 statements
      TooManyStatements: OptionParser::Switch#summarize has approx 28 statements
      TooManyStatements: OptionParser::Switch::PlacedArgument#parse has approx 6 statements
      UncommunicativeParameterName: OptionParser::List#accept has the parameter name 't'
      UncommunicativeParameterName: OptionParser::List#reject has the parameter name 't'
      UncommunicativeParameterName: OptionParser::Switch#self.incompatible_argument_styles has the parameter name 't'
      UncommunicativeVariableName: OptionParser has the variable name 'f'
      UncommunicativeVariableName: OptionParser has the variable name 'k'
      UncommunicativeVariableName: OptionParser has the variable name 'o'
      UncommunicativeVariableName: OptionParser has the variable name 's'
      UncommunicativeVariableName: OptionParser has the variable name 'v'
      UncommunicativeVariableName: OptionParser#load has the variable name 's'
      UncommunicativeVariableName: OptionParser#make_switch has the variable name 'a'
      UncommunicativeVariableName: OptionParser#make_switch has the variable name 'c'
      UncommunicativeVariableName: OptionParser#make_switch has the variable name 'n'
      UncommunicativeVariableName: OptionParser#make_switch has the variable name 'o'
      UncommunicativeVariableName: OptionParser#make_switch has the variable name 'q'
      UncommunicativeVariableName: OptionParser#make_switch has the variable name 's'
      UncommunicativeVariableName: OptionParser#make_switch has the variable name 'v'
      UncommunicativeVariableName: OptionParser#search has the variable name 'k'
      UncommunicativeVariableName: OptionParser#summarize has the variable name 'l'
      UncommunicativeVariableName: OptionParser#ver has the variable name 'v'
      UncommunicativeVariableName: OptionParser::Completion#complete has the variable name 'k'
      UncommunicativeVariableName: OptionParser::Completion#complete has the variable name 'v'
      UncommunicativeVariableName: OptionParser::List#update has the variable name 'o'
      UncommunicativeVariableName: OptionParser::Switch#add_banner has the variable name 's'
      UncommunicativeVariableName: OptionParser::Switch#parse_arg has the variable name 'm'
      UncommunicativeVariableName: OptionParser::Switch#parse_arg has the variable name 's'
      UncommunicativeVariableName: OptionParser::Switch#self.guess has the variable name 't'
      UncommunicativeVariableName: OptionParser::Switch#summarize has the variable name 'l'
      UncommunicativeVariableName: OptionParser::Switch#summarize has the variable name 'r'
      UncommunicativeVariableName: OptionParser::Switch#summarize has the variable name 's'
      UnusedParameters: OptionParser::Completion#convert has unused parameter 'opt'
      UnusedParameters: OptionParser::Switch::NoArgument#parse has unused parameter 'argv'
      UnusedParameters: OptionParser::Switch::OptionalArgument#parse has unused parameter 'argv'
    redcloth.rb -- 110 warnings:
      Attribute: RedCloth#filter_html is a writable attribute
      Attribute: RedCloth#filter_styles is a writable attribute
      Attribute: RedCloth#hard_breaks is a writable attribute
      Attribute: RedCloth#lite_mode is a writable attribute
      Attribute: RedCloth#no_span_caps is a writable attribute
      Attribute: RedCloth#rules is a writable attribute
      BooleanParameter: RedCloth#blocks has boolean parameter 'deep_code'
      ControlParameter: RedCloth#blocks is controlled by argument 'deep_code'
      ControlParameter: RedCloth#htmlesc is controlled by argument 'mode'
      ControlParameter: RedCloth#lT is controlled by argument 'text'
      ControlParameter: RedCloth#pba is controlled by argument 'element'
      DataClump: RedCloth takes parameters ['atts', 'cite', 'content', 'tag'] to 3 methods
      DuplicateMethodCall: RedCloth#block_textile_lists calls 'depth.last' 5 times
      DuplicateMethodCall: RedCloth#block_textile_lists calls 'depth.last.length' 2 times
      DuplicateMethodCall: RedCloth#block_textile_lists calls 'depth[i]' 2 times
      DuplicateMethodCall: RedCloth#block_textile_lists calls 'line_id - 1' 2 times
      DuplicateMethodCall: RedCloth#block_textile_lists calls 'lines[line_id - 1]' 2 times
      DuplicateMethodCall: RedCloth#block_textile_lists calls 'tl.length' 3 times
      DuplicateMethodCall: RedCloth#clean_html calls 'tags[tag]' 2 times
      DuplicateMethodCall: RedCloth#pba calls '$1.length' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls '@pre_list.last << line' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls '@pre_list.last' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls 'codepre - used_offtags.length > 0' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls 'codepre - used_offtags.length' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls 'codepre.zero?' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls 'htmlesc( line, :NoQuotes )' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls 'used_offtags.length' 2 times
      DuplicateMethodCall: RedCloth#rip_offtags calls 'used_offtags['notextile']' 3 times
      FeatureEnvy: RedCloth#block_markdown_atx refers to 'text' more than self (maybe move it to another class?)
      FeatureEnvy: RedCloth#block_markdown_setext refers to 'text' more than self (maybe move it to another class?)
      FeatureEnvy: RedCloth#block_textile_lists refers to 'depth' more than self (maybe move it to another class?)
      FeatureEnvy: RedCloth#blocks refers to 'blk' more than self (maybe move it to another class?)
      FeatureEnvy: RedCloth#clean_white_space refers to 'text' more than self (maybe move it to another class?)
      FeatureEnvy: RedCloth#pba refers to 'text' more than self (maybe move it to another class?)
      InstanceVariableAssumption: RedCloth assumes too much for instance variable '@lite_mode'
      InstanceVariableAssumption: RedCloth assumes too much for instance variable '@pre_list'
      InstanceVariableAssumption: RedCloth assumes too much for instance variable '@rules'
      InstanceVariableAssumption: RedCloth assumes too much for instance variable '@shelf'
      InstanceVariableAssumption: RedCloth assumes too much for instance variable '@urlrefs'
      LongParameterList: RedCloth#textile_bq has 4 parameters
      LongParameterList: RedCloth#textile_fn_ has 5 parameters
      LongParameterList: RedCloth#textile_p has 4 parameters
      ManualDispatch: RedCloth#block_textile_prefix manually dispatches method call
      NestedIterators: RedCloth#block_textile_lists contains iterators nested 3 deep
      NestedIterators: RedCloth#block_textile_table contains iterators nested 2 deep
      NestedIterators: RedCloth#block_textile_table contains iterators nested 3 deep
      NestedIterators: RedCloth#blocks contains iterators nested 2 deep
      NestedIterators: RedCloth#clean_html contains iterators nested 2 deep
      NestedIterators: RedCloth#inline contains iterators nested 2 deep
      NestedIterators: RedCloth#inline_textile_span contains iterators nested 2 deep
      RepeatedConditional: RedCloth tests 'atts' at least 6 times
      RepeatedConditional: RedCloth tests 'codepre.zero?' at least 3 times
      RepeatedConditional: RedCloth tests 'href' at least 3 times
      RepeatedConditional: RedCloth tests 'title' at least 4 times
      SubclassedFromCoreClass: RedCloth inherits from core class 'String'
      TooManyConstants: RedCloth has 45 constants
      TooManyMethods: RedCloth has at least 44 methods
      TooManyStatements: RedCloth#block_markdown_bq has approx 6 statements
      TooManyStatements: RedCloth#block_textile_lists has approx 21 statements
      TooManyStatements: RedCloth#block_textile_table has approx 19 statements
      TooManyStatements: RedCloth#blocks has approx 19 statements
      TooManyStatements: RedCloth#clean_html has approx 15 statements
      TooManyStatements: RedCloth#clean_white_space has approx 7 statements
      TooManyStatements: RedCloth#glyphs_textile has approx 10 statements
      TooManyStatements: RedCloth#inline_markdown_link has approx 6 statements
      TooManyStatements: RedCloth#inline_markdown_reflink has approx 8 statements
      TooManyStatements: RedCloth#inline_textile_image has approx 17 statements
      TooManyStatements: RedCloth#inline_textile_link has approx 9 statements
      TooManyStatements: RedCloth#inline_textile_span has approx 9 statements
      TooManyStatements: RedCloth#pba has approx 21 statements
      TooManyStatements: RedCloth#rip_offtags has approx 18 statements
      TooManyStatements: RedCloth#to_html has approx 26 statements
      UncommunicativeMethodName: RedCloth#lT has the name 'lT'
      UncommunicativeParameterName: RedCloth#textile_popup_help has the parameter name 'windowH'
      UncommunicativeParameterName: RedCloth#textile_popup_help has the parameter name 'windowW'
      UncommunicativeVariableName: RedCloth has the variable name 'a'
      UncommunicativeVariableName: RedCloth has the variable name 'b'
      UncommunicativeVariableName: RedCloth#block_textile_lists has the variable name 'i'
      UncommunicativeVariableName: RedCloth#block_textile_lists has the variable name 'v'
      UncommunicativeVariableName: RedCloth#block_textile_table has the variable name 'x'
      UncommunicativeVariableName: RedCloth#clean_html has the variable name 'q'
      UncommunicativeVariableName: RedCloth#clean_html has the variable name 'q2'
      UncommunicativeVariableName: RedCloth#initialize has the variable name 'r'
      UncommunicativeVariableName: RedCloth#inline_markdown_link has the variable name 'm'
      UncommunicativeVariableName: RedCloth#inline_markdown_reflink has the variable name 'm'
      UncommunicativeVariableName: RedCloth#inline_textile_code has the variable name 'm'
      UncommunicativeVariableName: RedCloth#inline_textile_image has the variable name 'href_a1'
      UncommunicativeVariableName: RedCloth#inline_textile_image has the variable name 'href_a2'
      UncommunicativeVariableName: RedCloth#inline_textile_image has the variable name 'm'
      UncommunicativeVariableName: RedCloth#inline_textile_link has the variable name 'm'
      UncommunicativeVariableName: RedCloth#inline_textile_span has the variable name 'm'
      UncommunicativeVariableName: RedCloth#refs_markdown has the variable name 'm'
      UncommunicativeVariableName: RedCloth#refs_textile has the variable name 'm'
      UncommunicativeVariableName: RedCloth#retrieve has the variable name 'i'
      UncommunicativeVariableName: RedCloth#retrieve has the variable name 'r'
      UnusedParameters: RedCloth#block_markdown_lists has unused parameter 'text'
      UnusedParameters: RedCloth#textile_bq has unused parameter 'tag'
      UnusedParameters: RedCloth#textile_fn_ has unused parameter 'cite'
      UnusedParameters: RedCloth#textile_fn_ has unused parameter 'tag'
      UnusedParameters: RedCloth#textile_p has unused parameter 'cite'
      UtilityFunction: RedCloth#block_markdown_rule doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#clean_html doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#flush_left doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#footnote_ref doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#h_align doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#htmlesc doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#incoming_entities doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#lT doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#no_textile doesn't depend on instance state (maybe move it to another class?)
      UtilityFunction: RedCloth#v_align doesn't depend on instance state (maybe move it to another class?)
    287 total warnings
    """
