require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/class_context'
require 'reek/stop_context'
require 'reek/code_parser'
require 'reek/smells/large_class'

include Reek
include Reek::Smells

describe LargeClass, 'checking source code' do

  context 'counting instance variables' do
    it 'should not report empty class' do
      ClassContext.from_s('class Empty;end').should have(0).variable_names
    end

    it 'should count ivars in one method' do
      ClassContext.from_s('class Empty;def ivars() @aa=@ab=@ac=@ad; end;end').should have(4).variable_names
    end

    it 'should count ivars in 2 methods' do
      ClassContext.from_s('class Empty;def iv1() @aa=@ab; end;def iv2() @aa=@ac; end;end').should have(3).variable_names
    end

    it 'should not report 9 ivars' do
      '# clean class for testing purposes
class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai; end;end'.should_not reek
    end

    it 'should report 10 ivars' do
      '# smelly class for testing purposes
class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj; end;end'.should reek_of(:LargeClass)
    end

    it 'should not report 10 ivars in 2 extensions' do
      src = <<EOS
# clean class for testing purposes
class Full;def ivars_a() @aa=@ab=@ac=@ad=@ae; end;end
# clean class for testing purposes
class Full;def ivars_b() @af=@ag=@ah=@ai=@aj; end;end
EOS

      src.should_not reek
    end
  end

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
      src.should_not reek
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
      src.should reek_of(:LargeClass)
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
      src.should_not reek_of(:LargeClass)
    end
  end
end

require 'spec/reek/smells/smell_detector_shared'

describe LargeClass do
  before(:each) do
    @detector = LargeClass.new
  end

  it_should_behave_like 'SmellDetector'
end
