require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/class_context'
require 'reek/stop_context'
require 'reek/smells/feature_envy'

include Reek
include Reek::Smells

describe ClassContext do
  it 'should report Long Parameter List' do
    ruby = 'class Inner; def simple(arga, argb, argc, argd) f(3);true end end'
    ruby.should reek_of(:LongParameterList, /Inner/, /simple/, /4 parameters/)
  end

  it 'should report two different methods' do
    src = <<EOEX
class Fred
  def simple(arga, argb, argc, argd) f(3);true end
  def simply(arga, argb, argc, argd) f(3);false end
end
EOEX
    src.should reek_of(:LongParameterList, /Fred/, /simple/)
    src.should reek_of(:LongParameterList, /Fred/, /simply/)
  end

  it 'should report many different methods' do
    src = <<EOEX
class Fred
    def textile_bq(tag, atts, cite, content) f(3);end
    def textile_p(tag, atts, cite, content) f(3);end
    def textile_fn_(tag, num, atts, cite, content) f(3);end
    def textile_popup_help(name, windowW, windowH) f(3);end
end
EOEX
    src.should reek_of(:LongParameterList, /Fred/, /textile_bq/)
    src.should reek_of(:LongParameterList, /Fred/, /textile_fn_/)
    src.should reek_of(:LongParameterList, /Fred/, /textile_p/)
  end
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
      @ctx = ClassContext.create(StopContext.new, [0, :Below])
    end

    it 'should recognise non-overridden method' do
      @ctx.is_overriding_method?('below').should == false
      @ctx.is_overriding_method?('above').should == false
    end

    it 'should recognise overridden method' do
      @ctx.is_overriding_method?('both').should == true
    end
    
    it 'should recognise methods in current codebase' do
      ctx = ClassContext.create(StopContext.new, [0, :FeatureEnvy])
      ctx.is_overriding_method?('examine_context').should == true
    end
  end
  
  describe 'of non-loaded class' do
    before :each do
      @ctx = ClassContext.create(StopContext.new, [0, :Missing])
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
    kelement = ClassContext.create(StopContext.new, [0, :FeatureEnvy, s(:const, :SmellDetector)])
    meth = Name.new(:examine_context)
    kelement.is_overriding_method?(meth).should == true
    melement = MethodContext.new(kelement, [0, :examine_context])
    melement.is_overriding_method?(meth).should == true
    melement.depends_on_instance?.should == true
  end
end

describe CodeContext, 'find class' do
  module Mod1
    class Klass1
      module Mod2
        class Klass2
        end
      end
    end
  end

  before :each do
    @stop = StopContext.new
    @mod1 = ModuleContext.create(@stop, [0, :Mod1])
    @klass1 = ClassContext.create(@mod1, [0, :Klass1])
    @mod2 = ModuleContext.create(@klass1, [0, :Mod2])
    @klass2 = ClassContext.create(@mod2, [0, :Klass2])
  end

  describe StopContext do
    it 'should not find unqualified class' do
      @stop.find_module('Klass2').should == nil
    end

    it 'should find unqualified module' do
      @stop.find_module('Mod1').name.should == 'Mod1'
    end
  end
  
  describe ModuleContext do
    it 'should find local name' do
      @mod1.find_module('Klass1').name.should == 'Mod1::Klass1'
      @mod2.find_module('Klass2').name.should == 'Mod1::Klass1::Mod2::Klass2'
    end
    
    it 'should not find deeper class' do
      @mod1.find_module('Klass2').should == nil
    end
    
    it 'should find own Module' do
      @mod1.myself.name.should == 'Mod1'
      @mod2.myself.name.should == 'Mod1::Klass1::Mod2'
    end
  end
  
  describe ClassContext do
    it 'should find local module' do
      @klass1.find_module('Mod2').name.should == 'Mod1::Klass1::Mod2'
    end
    
    it 'should not find deeper module' do
      @klass1.find_module('Klass2').should == nil
    end
    
    it 'should find own Class' do
      @klass1.myself.name.should == 'Mod1::Klass1'
      @klass2.myself.name.should == 'Mod1::Klass1::Mod2::Klass2'
    end
  end
end
