require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_instance_variables'

RSpec.describe Reek::Smells::TooManyInstanceVariables do
  context 'reporting smell' do
    it 'reports the smell parameters' do
      src = <<-EOS
        class Empty
          def ivars
            @a = @b = @c = @d = 1
            @e = 1
          end
        end
      EOS

      expect(src).to reek_of(described_class,
                             lines: [1],
                             count: 5,
                             message: 'has at least 5 instance variables',
                             context: 'Empty')
    end
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
      expect(src).not_to reek_of(described_class)
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
      expect(src).not_to reek_of(described_class)
    end

    it 'reeks of unneeded supression' do
      src = <<-EOS
        # :reek:TooManyInstanceVariables: { enabled: false }
        class Empty
          def ivars
            @a = @b = @c = @d = 1
          end
        end
      EOS
      expect(src).to reek_of(described_class, message: 'test', test: 'test')
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
      expect(src).not_to reek_of(described_class)
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
      expect(src).not_to reek_of(described_class)
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
      expect(src).not_to reek_of(described_class)
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
      expect(src).not_to reek_of(described_class)
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
      expect(src).to reek_of(described_class)
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
      expect(src).to reek_of(described_class)
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
      expect(src).not_to reek_of(described_class)
    end
  end
end
