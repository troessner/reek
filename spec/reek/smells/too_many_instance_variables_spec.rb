require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_instance_variables'

RSpec.describe Reek::Smells::TooManyInstanceVariables do
  it 'reports the right values' do
    src = <<-EOS
      class Empty
        def ivars
          @a = @b = @c = @d = 1
          @e = 1
        end
      end
    EOS

    expect(src).to reek_of(:TooManyInstanceVariables,
                           lines:   [1],
                           context: 'Empty',
                           message: 'has at least 5 instance variables',
                           source:  'string',
                           count:   5)
  end

  context 'counting instance variables' do
    it 'should not report for non-excessive ivars' do
      src = <<-EOS
        class Empty
          def ivars
            @a = @b = @c = @d = 1
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'has a configurable maximum' do
      src = <<-EOS
        # :reek:TooManyInstanceVariables: { max_instance_variables: 5 }
        class Empty
          def ivars
            @a = @b = @c = @d = 1
            @e = 1
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'counts each ivar only once' do
      src = <<-EOS
        class Empty
          def ivars
            @a = @b = @c = @d = 1
            @a = @b = @c = @d = 1
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'should not report memoized ivars' do
      src = <<-EOS
        class Empty
          def ivars
            @a = @b = @c = @d = 1
            @e ||= 1
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'should not count ivars on inner classes altogether' do
      src = <<-EOS
        class Empty
          class InnerA
            def ivars
              @a = @b = @c = @d = 1
            end
          end

          class InnerB
            def ivars
              @e = 1
            end
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'should not count ivars on modules altogether' do
      src = <<-EOS
        class Empty
          class InnerA
            def ivars
              @a = @b = @c = @d = 1
            end
          end

          module InnerB
            def ivars
              @e = 1
            end
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end

    it 'reports excessive ivars' do
      src = <<-EOS
        class Empty
          def ivars
            @a = @b = @c = @d = 1
            @e = 1
          end
        end
      EOS
      expect(src).to reek_of(:TooManyInstanceVariables)
    end

    it 'reports excessive ivars even in different methods' do
      src = <<-EOS
        class Empty
          def ivars_a
            @a = @b = @c = @d = 1
          end

          def ivars_b
            @e = 1
          end
        end
      EOS
      expect(src).to reek_of(:TooManyInstanceVariables)
    end

    it 'should not report for ivars in 2 extensions' do
      src = <<-EOS
        class Full
          def ivars_a
            @a = @b = @c = @d = 1
          end
        end

        class Full
          def ivars_b
            @a = @b = @c = @d = 1
          end
        end
      EOS
      expect(src).not_to reek_of(:TooManyInstanceVariables)
    end
  end
end
