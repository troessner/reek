require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'source', 'sexp_formatter')

include Reek::Source

describe SexpFormatter do
  describe "::format" do
    it 'formats a simple s-expression' do
      result = SexpFormatter.format s(:lvar, :foo)
      result.should == "foo"
    end

    it 'formats a more complex s-expression' do
      result = SexpFormatter.format s(:call, nil, :foo, s(:arglist, s(:lvar, :bar)))
      result.should == "foo(bar)"
    end
  end
end

