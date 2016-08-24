require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_constants'

RSpec.describe Reek::Smells::TooManyConstants do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        A = B = C = D = E = F = 1
      end
    EOS

    expect(src).to reek_of(:TooManyConstants,
                           lines:   [1],
                           context: 'Dummy',
                           message: 'has 6 constants',
                           source:  'string',
                           count:   6)
  end

  context 'counting constants' do
    it 'should not report for non-excessive constants' do
      src = <<-EOS
        class Dummy
          A = B = C = D = E = 1
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants)
    end

    it 'should not report when increasing default' do
      src = <<-EOS
        # :reek:TooManyConstants: { max_constants: 6 }
        class Dummy
          A = B = C = D = E = 1
          F = 1
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants)
    end

    it 'should not report when disabled' do
      src = <<-EOS
        # :reek:TooManyConstants: { enabled: false }
        class Dummy
          A = B = C = D = E = 1
          F = 1
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants)
    end

    it 'should not account class definition' do
      src = <<-EOS
        module Dummiest
          class Dummy
            A = B = C = D = E = 1

            Error = Class.new(StandardError)
          end
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants)
    end

    it 'should not account struct definition' do
      src = <<-EOS
        module Dummiest
          class Dummy
            A = B = C = D = E = 1

            Struct = Struct.new
          end
        end
      EOS

      expect(src).to_not reek_of(:TooManyConstants)
    end

    it 'should count each constant only once' do
      src = <<-EOS
        class Good
          A = B = C = D = E = 1
        end

        class Bad
          A = B = C = D = E = 1
        end

        class Ugly
          A = B = C = D = E = 1
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants)
    end

    it 'should count each constant only once for each class' do
      src = <<-EOS
        module Movie
          class Good
            A = B = C = D = E = 1
          end

          class Bad
            F = G = H = I = J = 1
          end

          class Ugly
            K = L = M = N = O = 1
          end
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants)
    end

    it 'should not report outer module when inner module suppressed' do
      src = <<-EOS
        module Foo
          # ignore :reek:TooManyConstants:
          module Bar
            A = 1
            B = 2
            C = 3
            D = 4
            E = 5
            F = 6
          end
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants, context: 'Foo')
    end

    it 'should count each constant only once for each namespace' do
      src = <<-EOS
        module Movie
          A = B = C = D = E = 1

          class Good
            F = 1
          end
        end
      EOS

      expect(src).not_to reek_of(:TooManyConstants)
    end

    it 'should report for excessive constants inside a class' do
      src = <<-EOS
        class Dummy
          A = B = C = D = E = 1
          F = 1
        end
      EOS

      expect(src).to reek_of(:TooManyConstants)
    end

    it 'should report for excessive constants inside a module' do
      src = <<-EOS
        module Dummiest
          A = B = C = D = E = 1
          F = 1

          class Dummy
          end
        end
      EOS

      expect(src).to reek_of(:TooManyConstants, context: 'Dummiest')
    end
  end

  context 'smell report' do
    it 'reports the number of constants' do
      src = <<-EOS
        module Moduly
          class Klass
            A = B = C = D = E = 1
            F = 1
          end
        end
      EOS

      expect(src).to reek_of(:TooManyConstants, count: 6)
    end

    it 'reports the line where it occurs' do
      src = <<-EOS
        module Moduly
          class Klass
            A = B = C = D = E = 1
            F = 1
          end
        end
      EOS

      expect(src).to reek_of(:TooManyConstants, lines: [2])
    end

    it 'reports a readable message' do
      src = <<-EOS
        module Moduly
          class Klass
            A = B = C = D = E = 1
            F = 1
          end
        end
      EOS

      expect(src).to reek_of(:TooManyConstants, message: 'has 6 constants')
    end

    context 'context' do
      it 'reports the full class name' do
        src = <<-EOS
          module Moduly
            class Klass
              A = B = C = D = E = 1
              F = 1
            end
          end
        EOS

        expect(src).to reek_of(:TooManyConstants, context: 'Moduly::Klass')
      end

      it 'reports the module name' do
        src = <<-EOS
          module Moduly
            A = B = C = D = E = 1
            F = 1

            class Klass
            end
          end
        EOS

        expect(src).to reek_of(:TooManyConstants, context: 'Moduly')
      end
    end
  end
end
