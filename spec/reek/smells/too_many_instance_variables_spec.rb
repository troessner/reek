require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_instance_variables'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::TooManyInstanceVariables do
  let(:detector) { build(:smell_detector, smell_type: :TooManyInstanceVariables) }

  it_should_behave_like 'SmellDetector'

  def default_max_ivars
    Reek::Smells::TooManyInstanceVariables::DEFAULT_MAX_IVARS
  end

  def too_many_ivars
    default_max_ivars + 1
  end

  def ivar_sequence(count: default_max_ivars, alphabet: ('a'..'z').to_a)
    alphabet.first(count).map do |name|
      "@#{name}=#{rand}"
    end.join(',')
  end

  context 'counting instance variables' do
    it 'should not report for non-excessive ivars' do
      src = <<-EOS
        class Empty
          def ivars
           #{ivar_sequence}
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'counts each ivar only once' do
      src = <<-EOS
        class Empty
          def ivars
           #{ivar_sequence}
           #{ivar_sequence}
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'should report excessive ivars' do
      src = <<-EOS
        class Empty
          def ivars
            #{ivar_sequence(count: too_many_ivars)}
          end
        end
      EOS
      expect(src).to reek_of(:TooManyInstanceVariables)
    end

    it 'should not report for ivars in 2 extensions' do
      src = <<-EOS
        class Full
          def ivars_a
            #{ivar_sequence}
          end
        end

        class Full
          def ivars_b
            #{ivar_sequence}
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end
  end

  context 'when a smell is reported' do
    let(:warning) do
      src = <<-EOS
        # Comment
        class Empty
          def ivars
            #{ivar_sequence(count: too_many_ivars)}
          end
        end
      EOS
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      detector.inspect(ctx).first
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(warning.parameters[:count]).to eq(too_many_ivars)
      expect(warning.lines).to eq([2])
    end
  end
end
