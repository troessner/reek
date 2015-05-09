require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/too_many_instance_variables'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::TooManyInstanceVariables do
  before(:each) do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :TooManyInstanceVariables, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'counting instance variables' do
    it 'should not report 9 ivars' do
      src = <<-EOS
        class Empty
          def ivars
            @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=4
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'counts each ivar only once' do
      src = <<-EOS
        class Empty
          def ivars
            @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=4
            @aa=3
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'should report 10 ivars' do
      src = <<-EOS
        class Empty
          def ivars
            @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj=4
          end
        end
      EOS
      expect(src).to reek_of(:TooManyInstanceVariables)
    end

    it 'should not report 10 ivars in 2 extensions' do
      src = <<-EOS
        class Full
          def ivars_a
            @aa=@ab=@ac=@ad=@ae
          end
        end

        class Full
          def ivars_b
            @af=@ag=@ah=@ai=@aj
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end
  end

  it 'reports correctly when the class has 10 instance variables' do
    src = <<-EOS
      # Comment
      class Empty
        def ivars
          @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj=4
        end
      end
    EOS
    ctx = Reek::Core::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
    @warning = @detector.examine_context(ctx)[0]
    expect(@warning.source).to eq(@source_name)
    expect(@warning.smell_category).to eq(Reek::Smells::TooManyInstanceVariables.smell_category)
    expect(@warning.smell_type).to eq(Reek::Smells::TooManyInstanceVariables.smell_type)
    expect(@warning.parameters[:count]).to eq(10)
    expect(@warning.lines).to eq([2])
  end
end
