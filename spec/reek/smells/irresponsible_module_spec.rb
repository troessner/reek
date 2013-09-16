require 'spec_helper'
require 'reek/smells/irresponsible_module'
require 'reek/smells/smell_detector_shared'
include Reek::Smells

describe IrresponsibleModule do
  before(:each) do
    @bad_module_name = 'WrongUn'
    @detector = IrresponsibleModule.new('yoof')
  end

  it_should_behave_like 'SmellDetector'

  it 'does not report re-opened modules' do
    src = <<-EOS
      # Abstract base class
      class C; end

      class C; def foo; end; end
    EOS
    src.should_not reek_of(:IrresponsibleModule)
  end

  it "does not report a class having a comment" do
    src = <<EOS
# test class
class Responsible; end
EOS
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    @detector.examine_context(ctx).should be_empty
  end
  it "reports a class without a comment" do
    src = "class #{@bad_module_name}; end"
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    smells = @detector.examine_context(ctx)
    smells.length.should == 1
    smells[0].smell_class.should == IrresponsibleModule::SMELL_CLASS
    smells[0].subclass.should == IrresponsibleModule::SMELL_SUBCLASS
    smells[0].lines.should == [1]
    smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY].should == @bad_module_name
  end
  it "reports a class with an empty comment" do
    src = <<EOS
#
#
#  
class #{@bad_module_name}; end
EOS
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    smells = @detector.examine_context(ctx)
    smells.length.should == 1
    smells[0].smell_class.should == IrresponsibleModule::SMELL_CLASS
    smells[0].subclass.should == IrresponsibleModule::SMELL_SUBCLASS
    smells[0].lines.should == [4]
    smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY].should == @bad_module_name
  end
  it 'reports a fq module name correctly' do
    src = 'class Foo::Bar; end'
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    smells = @detector.examine_context(ctx)
    smells.length.should == 1
    smells[0].smell_class.should == IrresponsibleModule::SMELL_CLASS
    smells[0].subclass.should == IrresponsibleModule::SMELL_SUBCLASS
    smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY].should == 'Foo::Bar'
    smells[0].context.should match(/#{smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY]}/)
  end
end
