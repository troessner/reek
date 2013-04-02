require 'spec_helper'
require 'reek/smells/too_many_methods'
require 'reek/examiner'
require 'reek/core/code_parser'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe TooManyMethods do
  before(:each) do
    @source_name = 'elephant'
    @detector = TooManyMethods.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'counting methods' do

    it 'should not report 25 methods' do
      src = <<EOS
# smelly class for testing purposes
class Full
  def me01x()3 end;def me02x()3 end;def me03x()3 end;def me04x()3 end;def me05x()3 end
  def me11x()3 end;def me12x()3 end;def me13x()3 end;def me14x()3 end;def me15x()3 end
  def me21x()3 end;def me22x()3 end;def me23x()3 end;def me24x()3 end;def me25x()3 end
  def me31x()3 end;def me32x()3 end;def me33x()3 end;def me34x()3 end;def me35x()3 end
  def me41x()3 end;def me42x()3 end;def me43x()3 end;def me44x()3 end;def me45x()3 end
end
EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine_context(ctx).should be_empty
    end

    it 'should report 26 methods' do
      src = <<EOS
class Full
  def me01x()3 end;def me02x()3 end;def me03x()3 end;def me04x()3 end;def me05x()3 end
  def me11x()3 end;def me12x()3 end;def me13x()3 end;def me14x()3 end;def me15x()3 end
  def me21x()3 end;def me22x()3 end;def me23x()3 end;def me24x()3 end;def me25x()3 end
  def me31x()3 end;def me32x()3 end;def me33x()3 end;def me34x()3 end;def me35x()3 end
  def me41x()3 end;def me42x()3 end;def me43x()3 end;def me44x()3 end;def me45x()3 end
  def me51x()3 end
end
EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine_context(ctx)
      smells.length.should == 1
      smells[0].subclass.should == TooManyMethods::SMELL_SUBCLASS
      smells[0].smell[TooManyMethods::METHOD_COUNT_KEY].should == 26
    end
  end

  context 'with a nested module' do
    it 'stops at a nested module' do
      src = <<EOS
class Full
  def me01x()3 end;def me02x()3 end;def me03x()3 end;def me04x()3 end;def me05x()3 end
  def me11x()3 end;def me12x()3 end;def me13x()3 end;def me14x()3 end;def me15x()3 end
  def me21x()3 end;def me22x()3 end;def me23x()3 end;def me24x()3 end;def me25x()3 end
  def me31x()3 end;def me32x()3 end;def me33x()3 end;def me34x()3 end;def me35x()3 end
  module Hidden; def me41x()3 end;def me42x()3 end;def me43x()3 end;def me44x()3 end;def me45x()3 end; end
  def me51x()3 end
end
EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine_context(ctx).should be_empty
    end
  end

  it 'reports correctly when the class has many methods' do
    src = <<EOS
class Full
  def me01x()3 end;def me02x()3 end;def me03x()3 end;def me04x()3 end;def me05x()3 end
  def me11x()3 end;def me12x()3 end;def me13x()3 end;def me14x()3 end;def me15x()3 end
  def me21x()3 end;def me22x()3 end;def me23x()3 end;def me24x()3 end;def me25x()3 end
  def me31x()3 end;def me32x()3 end;def me33x()3 end;def me34x()3 end;def me35x()3 end
  def me41x()3 end;def me42x()3 end;def me43x()3 end;def me44x()3 end;def me45x()3 end
  def me51x()3 end
end
EOS
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    @warning = @detector.examine_context(ctx)[0]
    @warning.source.should == @source_name
    @warning.smell_class.should == 'LargeClass'
    @warning.subclass.should == TooManyMethods::SMELL_SUBCLASS
    @warning.smell[TooManyMethods::METHOD_COUNT_KEY].should == 26
    @warning.lines.should == [1]
  end
end
