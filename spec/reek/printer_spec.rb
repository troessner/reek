require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/checker'
require 'reek/printer'

include Reek

def check(examples)
  examples.each do |actual|
    it "should format #{actual} correctly" do
      sexp = Checker.parse_tree_for(actual)[0]
      Printer.print(sexp).should == actual
    end
  end
end

describe Printer do
  check 'Alpha'
  check 'Alpha::Beta'
  check '@@fred'
  check '`ls`'
  check 'array[0]'
  check 'array[0, 1, 2]'
  check 'obj.method(arg1, arg2)'
  check 'obj.method'
  check '$1'
  check 'o=q.downcase'
  check 'true'
  check '"-#{q}xxx#{z.size}"'
end
