require_relative '../../spec_helper'
require_lib 'reek/context/code_context'
require_lib 'reek/smells/nil_check'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::NilCheck do
  it 'reports correctly the basic use case' do
    src = <<-EOS
      def foo(bar)
        bar.nil?
      end
    EOS
    expect(src).to reek_of :NilCheck,
                           lines: [2],
                           message: 'performs a nil-check'
  end

  it 'reports nothing when scope includes no nil checks' do
    expect('def no_nils; end').not_to reek_of(:NilCheck)
  end

  it 'reports when scope uses #nil?' do
    src = <<-EOS
    def foo(bar)
      bar.nil?
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses == nil' do
    src = <<-EOS
    def foo(bar)
      bar == nil
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses === nil' do
    src = <<-EOS
    def foo(bar)
      bar === nil
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses nil ==' do
    src = <<-EOS
    def foo(bar)
      nil == bar
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses a case-clause checking nil' do
    src = <<-EOS
    def case_nil
      case @foo
      when nil then puts "Nil"
      end
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses &.' do
    src = <<-EOS
    def foo(bar)
      bar&.baz
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports all lines when scope uses multiple nilchecks' do
    src = <<-EOS
    def foo(bar)
      bar.nil?
      bar === nil
      bar&.baz
    end
    EOS
    expect(src).to reek_of(:NilCheck, lines: [2, 3, 4])
  end
end
