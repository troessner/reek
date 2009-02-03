require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'
require 'reek/sexp_formatter'

include Reek

def should_print(example)
  it "should format #{example} correctly" do
    sexp = CodeParser.parse_tree_for(example)[0]
    SexpFormatter.format(sexp).should == example
  end
end

describe SexpFormatter do
  should_print 'self'
  should_print 'Alpha'
  should_print 'Alpha::Beta'
  should_print '@@fred'
  should_print '`ls`'
  should_print 'array[0]'
  should_print 'array[0, 1, 2]'
  should_print 'obj.method(arg1, arg2)'
  should_print 'obj.method'
  should_print '$1'
  should_print 'o=q.downcase'
  should_print 'true'
  should_print '"-#{q}xxx#{z.size}"'
  should_print '0..5'
  should_print '0..temp'
end
