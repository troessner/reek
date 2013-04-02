require 'spec_helper'
require 'reek/smells/too_many_instance_variables'
require 'reek/examiner'
require 'reek/core/code_parser'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe TooManyInstanceVariables do
  before(:each) do
    @source_name = 'elephant'
    @detector = TooManyInstanceVariables.new(@source_name)
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
class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj=4; end;end'.should reek_only_of(:TooManyInstanceVariables)
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

  it 'reports correctly when the class has 10 instance variables' do
    src = <<EOS
# smelly class for testing purposes
class Empty
  def ivars
    @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj=4
  end
end
EOS
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    @warning = @detector.examine_context(ctx)[0]
    @warning.source.should == @source_name
    @warning.smell_class.should == 'LargeClass'
    @warning.subclass.should == TooManyInstanceVariables::SMELL_SUBCLASS
    @warning.smell[TooManyInstanceVariables::IVAR_COUNT_KEY].should == 10
    @warning.lines.should == [2]
  end
end
