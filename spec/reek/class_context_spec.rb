require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'spec/reek/code_checks'
require 'reek/class_context'

include CodeChecks
include Reek

describe ClassContext do
  check 'should report Long Parameter List',
    'class Inner; def simple(arga, argb, argc, argd) f(3);true end end', [[/Inner/, /simple/, /4 parameters/]]

    src = <<EOEX
class Fred
  def simple(arga, argb, argc, argd) f(3);true end
  def simply(arga, argb, argc, argd) f(3);false end
end
EOEX
  check 'should report two different methods', src, [[/Fred/, /simple/], [/Fred/, /simply/]]

    src = <<EOEX
class Fred
    def textile_bq(tag, atts, cite, content) f(3);end
    def textile_p(tag, atts, cite, content) f(3);end
    def textile_fn_(tag, num, atts, cite, content) f(3);end
    def textile_popup_help(name, windowW, windowH) f(3);end
end
EOEX
  check 'should report many different methods', src,
    [[/Fred/, /textile_bq/], [/Fred/, /textile_fn_/], [/Fred/, /textile_p/]]
end

describe Class do
  
  module Insert
    def meth_a() end
  private
    def meth_b() end
  protected
    def meth_c() end
  end

  class Parent
    def meth1() end
  private
    def meth2() end
  protected
    def meth3() end
  end
  
  class FullChild < Parent
    include Insert
    def meth7() end
  private
    def meth8() end
  protected
    def meth6() end
  end

  describe 'with no superclass or modules' do
    it 'should report correct number of methods' do
      Parent.non_inherited_methods.length.should == 3
    end
  end

  describe 'with superclass and modules' do
    it 'should report correct number of methods' do
      FullChild.non_inherited_methods.length.should == 3
    end
  end
end

describe ClassContext, 'overridden methods' do
  class Above
    def above() end
    def both() end
  end
  
  class Below < Above
    def both() end
    def below() end
  end
  
  describe 'of loaded class' do
    before :each do
      @ctx = ClassContext.new(StopContext.new, [0, :Below])
    end

    it 'should recognise non-overridden method' do
      @ctx.is_overriding_method?('below').should == false
      @ctx.is_overriding_method?('above').should == false
    end

    it 'should recognise overridden method' do
      @ctx.is_overriding_method?('both').should == true
    end
    
    it 'should recognise methods in current codebase' do
      ctx = ClassContext.new(StopContext.new, [0, :FeatureEnvy])
      ctx.is_overriding_method?('examine_context').should == true
    end
  end
  
  describe 'of non-loaded class' do
    before :each do
      @ctx = ClassContext.new(StopContext.new, [0, :Missing])
    end

    it 'should recognise non-overridden method' do
      @ctx.is_overriding_method?('below').should == false
      @ctx.is_overriding_method?('above').should == false
    end

    it 'should recognise overridden method' do
      @ctx.is_overriding_method?('both').should == false
    end
  end
end

describe 'Integration defect:' do
  it 'should not report UtilityFunction for FeatureEnvy#examine_context' do
    kelement = ClassContext.new(StopContext.new, [0, :FeatureEnvy, s(:const, :SmellDetector)])
    meth = Name.new(:examine_context)
    kelement.is_overriding_method?(meth).should == true
    melement = MethodContext.new(kelement, [0, :examine_context])
    melement.is_overriding_method?(meth).should == true
    melement.depends_on_instance?.should == true
  end
end
