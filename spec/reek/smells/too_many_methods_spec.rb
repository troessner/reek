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
      ctx = ModuleContext.new(nil, src.to_reek_source.syntax_tree)
      expect(@detector.examine_context(ctx)).to be_empty
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
      ctx = ModuleContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine_context(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_type).to eq(TooManyMethods.smell_type)
      expect(smells[0].parameters[:count]).to eq(26)
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
  module Hidden
    def me41x()3 end
    def me42x()3 end
    def me43x()3 end
    def me44x()3 end
    def me45x()3 end
  end
  def me51x()3 end
end
EOS
      ctx = ModuleContext.new(nil, src.to_reek_source.syntax_tree)
      expect(@detector.examine_context(ctx)).to be_empty
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
    ctx = ModuleContext.new(nil, src.to_reek_source.syntax_tree)
    @warning = @detector.examine_context(ctx)[0]
    expect(@warning.source).to eq(@source_name)
    expect(@warning.smell_category).to eq(TooManyMethods.smell_category)
    expect(@warning.smell_type).to eq(TooManyMethods.smell_type)
    expect(@warning.parameters[:count]).to eq(26)
    expect(@warning.lines).to eq([1])
  end
end
