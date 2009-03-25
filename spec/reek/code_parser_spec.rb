require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'
require 'reek/report'
require 'spec/reek/code_checks'

include CodeChecks
include Reek

describe CodeParser, "with no method definitions" do
  check 'should report no problems for empty source code', '', []
  check 'should report no problems for empty class', 'class Fred; end', []
end

describe CodeParser, 'with a global method definition' do
  check 'should report no problems for simple method',
    'def Outermost::fred() true; end', []
end

describe CodeParser, 'when given a C extension' do
  before(:each) do
    @cchk = CodeParser.new(Report.new, SmellConfig.new.smell_listeners)
  end

  it 'should ignore :cfunc' do
    @cchk.check_object(Enumerable)
  end
end

describe CodeParser, 'when a yield is the receiver' do
  source = 'def values(*args)
  @to_sql += case
    when block_given? then " #{yield.to_sql}"
    else " values (#{args.to_sql})"
  end
  self
end'
  check 'should report no problems', source, []
end
