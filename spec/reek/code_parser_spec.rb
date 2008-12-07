require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'
require 'reek/report'

include Reek

describe CodeParser, "with no method definitions" do  
  before(:each) do
    @rpt = Report.new
    @cchk = CodeParser.new(@rpt)
  end

  it 'should report no problems for empty source code' do
    @cchk.check_source('')
    @rpt.should be_empty
  end

  it 'should report no problems for empty class' do
    @cchk.check_source('class Fred; end')
    @rpt.should be_empty
  end
end

describe CodeParser, 'when given a C extension' do
  before(:each) do
    @cchk = CodeParser.new(Report.new)
  end

  it 'should ignore :cfunc' do
    @cchk.check_object(Enumerable)
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
    rpt = Report.new
    chk = CodeParser.new(rpt)
    chk.check_source(source)
    rpt.should be_empty
  end
end
