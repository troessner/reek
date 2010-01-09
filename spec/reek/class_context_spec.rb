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
# module for test
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
# module for test
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

describe ClassContext do
  it 'does not report empty class in another module' do
    '# module for test
class Treetop::Runtime::SyntaxNode; end'.should_not reek
  end

  it 'deals with :: scoped names' do
    element = ClassContext.create(StopContext.new, [:colon2, [:colon2, [:const, :Treetop], :Runtime], :SyntaxNode])
    element.num_methods.should == 0
  end
end
