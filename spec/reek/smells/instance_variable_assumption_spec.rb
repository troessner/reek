require_relative '../../spec_helper'

require_lib 'reek/smells/instance_variable_assumption'

RSpec.describe Reek::Smells::InstanceVariableAssumption do
  describe 'warning' do
    context 'smell line' do
      it 'should report the lines' do
        src = <<-EOS
          class Dummy
            def test
              @a
            end
          end
        EOS

        expect(src).to reek_of(:InstanceVariableAssumption, lines: [1])
      end
    end

    context 'smell parameters' do
      it 'should report the lines' do
        src = <<-EOS
          class Dummy
            def test
              @a
            end
          end
        EOS

        expect(src).to reek_of(:InstanceVariableAssumption, assumptions: [:@a])
      end
    end

    context 'smell context' do
      it 'should report the context' do
        src = <<-EOS
          class Dummy
            def test
              @a
            end
          end
        EOS

        expect(src).to reek_of(:InstanceVariableAssumption, context: 'Dummy')
      end
    end

    context 'smell message' do
      it 'should report the ivars in the message' do
        message = 'assumes too much for instance variable @a, @b'

        src = <<-EOS
          class Dummy
            def test
              [@a, @b]
            end
          end
        EOS

        expect(src).to reek_of(:InstanceVariableAssumption, message: message)
      end

      it 'should report each ivar once' do
        message = 'assumes too much for instance variable @a, @b, @c'

        src = <<-EOS
          class Dummy
            def test
              [@a, @a, @b, @c]
            end

            def retest
              @c
            end
          end
        EOS

        expect(src).to reek_of(:InstanceVariableAssumption, message: message)
      end
    end
  end

  it 'should not report an empty class' do
    src = <<-EOS
      class Dummy
      end
    EOS

    expect(src).not_to reek_of(:InstanceVariableAssumption)
  end

  it 'should not report when lazy initializing' do
    src = <<-EOS
      class Dummy
        def test
          @a ||= 1
        end
      end
    EOS

    expect(src).not_to reek_of(:InstanceVariableAssumption)
  end

  it 'should report when making instance variable assumption' do
    src = <<-EOS
      class Dummy
        def test
          @a
        end
      end
    EOS

    expect(src).to reek_of(:InstanceVariableAssumption)
  end

  it 'should report any initialization outside initialize' do
    src = <<-EOS
      class Dummy
        def initialize
          @a = 1
        end

        def test
          [@a, @b]
        end
      end
    EOS

    expect(src).to reek_of(:InstanceVariableAssumption)
  end

  context 'inner classes' do
    it 'should not report inner class' do
      src = <<-EOS
        class Dummy
          class Dummiest
            def initialize
              @a = 1
            end

            def test
              @a
            end
          end
        end
      EOS

      expect(src).not_to reek_of(:InstanceVariableAssumption)
    end

    it 'should report outter class' do
      src = <<-EOS
        class Dummy
          def test
            @a = 1
          end

          class Dummiest
          end
        end
      EOS

      expect(src).to reek_of(:InstanceVariableAssumption, context: 'Dummy')
    end

    it 'should report even if outer class initialize the variable' do
      src = <<-EOS
        class Dummy
          def initialize
            @a = 1
          end

          class Dummiest
            def test
              @a
            end
          end
        end
      EOS

      expect(src).to reek_of(:InstanceVariableAssumption, context: 'Dummy::Dummiest')
    end

    it 'should report inner classes' do
      src = <<-EOS
        class Dummy
          def initialize
            @a = 1
          end

          class Dummiest
            def initialize
              @b = 1
            end

            def test
              @c
            end
          end
        end
      EOS

      expect(src).to reek_of(:InstanceVariableAssumption, context: 'Dummy::Dummiest')
    end
  end
end
