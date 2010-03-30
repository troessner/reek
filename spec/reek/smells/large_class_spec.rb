require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'large_class')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'examiner')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'code_parser')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe LargeClass do
  before(:each) do
    @source_name = 'elephant'
    @detector = LargeClass.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'counting instance variables' do
    it 'should not report 9 ivars' do
      '# clean class for testing purposes
class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=4; end;end'.should_not reek
    end

    it 'counts each ivar only once' do
      '# clean class for testing purposes
class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=4;@aa=3; end;end'.should_not reek
    end

    it 'should report 10 ivars' do
      '# smelly class for testing purposes
class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj=4; end;end'.should reek_only_of(:LargeClass)
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
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine(ctx)
      @detector.smells_found.should be_empty
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
      @detector.examine(ctx)
      smells = @detector.smells_found.to_a
      smells.length.should == 1
      smells[0].subclass.should == LargeClass::SUBCLASS_TOO_MANY_METHODS
      smells[0].smell[LargeClass::METHOD_COUNT_KEY].should == 26
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
      @detector.examine(ctx)
      @detector.smells_found.should be_empty
    end
  end

  context 'when the class has many methods' do
    before :each do
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
      @detector.examine(ctx)
      @warning = @detector.smells_found.to_a[0]
    end
    it 'reports the source' do
      @warning.source.should == @source_name
    end
    it 'reports the correct class' do
      @warning.smell_class.should == 'LargeClass'
    end
    it 'reports the correct subclass' do
      @warning.subclass.should == LargeClass::SUBCLASS_TOO_MANY_METHODS
    end
    it 'reports the number of methods' do
      @warning.smell['method_count'].should == 26
    end
    it 'reports the line number of the declaration' do
      @warning.lines.should == [1]
    end
  end

  context 'when the class has 30 instance variables' do
    before :each do
      src = <<EOS
# smelly class for testing purposes
class Empty
  def ivars
    @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj=4
  end
end
EOS
      source = src.to_reek_source
      sniffer = Core::Sniffer.new(source)
      ctx = Core::CodeParser.new(sniffer).process_class(source.syntax_tree)
      @detector.examine_context(ctx)
      @yaml = @detector.smells_found.to_a[0].to_yaml   # SMELL: too cumbersome!
    end
    it 'reports the source' do
      @yaml.should match(/source:\s*#{@source_name}/)
    end
    it 'reports the correct class' do
      @yaml.should match(/\sclass:\s*LargeClass/)
    end
    it 'reports the correct subclass' do
      @yaml.should match(/\ssubclass:\s*#{LargeClass::SUBCLASS_TOO_MANY_IVARS}/)
    end
    it 'reports the number of methods' do
      @yaml.should match(/ivar_count:\s*10/)
      # SMELL: many tests duplicate the names of the YAML fields
    end
    it 'reports the line number of the declaration' do
      @yaml.should match(/lines:\s*- 2/)
    end
  end
end
