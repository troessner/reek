require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'
require 'reek/report'

include Reek

describe CodeParser, "with no method definitions" do
  it 'should report no problems for empty source code' do
    ''.should_not reek
  end
  it 'should report no problems for empty class' do
    'class Fred; end'.should_not reek
  end
end

describe CodeParser, 'with a global method definition' do
  it 'should report no problems for simple method' do
    'def Outermost::fred() true; end'.should_not reek
  end
end

describe CodeParser, 'when a yield is the receiver' do
  it 'should report no problems' do
    source = 'def values(*args)
  @to_sql += case
    when block_given? then " #{yield.to_sql}"
    else " values (#{args.to_sql})"
  end
  self
end'
    source.should_not reek
  end
end
