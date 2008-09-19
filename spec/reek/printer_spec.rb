require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/smells'
require 'reek/report'

include Reek

def render(source)
  sexp = Checker.parse_tree_for(source)[0]
  Printer.print(sexp)
end

describe Printer do
  it 'should format a simple constant' do
    render('Alpha').should == 'Alpha'
  end

  it 'should format "::" correctly' do
    render('Alpha::Beta').should == 'Alpha::Beta'
  end

  it 'should format class variables correctly' do
    render('@@fred').should == '@@fred'
  end
end
