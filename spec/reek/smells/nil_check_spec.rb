require_relative '../../spec_helper'
require_lib 'reek/smells/nil_check'

RSpec.describe Reek::Smells::NilCheck do
  it 'reports the right values' do
    src = <<-EOS
      def m(arg)
        arg.nil?
      end
    EOS

    expect(src).to reek_of(:NilCheck,
                           lines:   [2],
                           context: 'm',
                           message: 'performs a nil-check',
                           source:  'string')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def m1(arg1, arg2)
        arg1.nil?
        arg2.nil?
      end
    EOS

    expect(src).to reek_of(:NilCheck,
                           lines:   [2, 3],
                           context: 'm1')
  end

  it 'reports nothing when scope includes no nil checks' do
    expect('def no_nils; end').not_to reek_of(:NilCheck)
  end

  it 'reports when scope uses == nil' do
    src = <<-EOS
      def m(arg)
        arg == nil
      end
    EOS

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses === nil' do
    src = <<-EOS
      def m(arg)
        arg === nil
      end
    EOS

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses nil ==' do
    src = <<-EOS
      def m(arg)
        nil == arg
      end
    EOS

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses a case-clause checking nil' do
    src = <<-EOS
      def case_nil(arg)
        case arg
        when nil then puts "Nil"
        end
      end
    EOS

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses &.' do
    src = <<-EOS
      def m(arg)
        arg&.baz
      end
    EOS

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports all lines when scope uses multiple nilchecks' do
    src = <<-EOS
      def foo(arg)
        arg.nil?
        arg === nil
        arg&.baz
      end
    EOS
    expect(src).to reek_of(:NilCheck, lines: [2, 3, 4])
  end
end
