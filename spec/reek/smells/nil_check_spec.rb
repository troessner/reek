require_relative '../../spec_helper'
require_lib 'reek/context/code_context'
require_lib 'reek/smells/nil_check'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::NilCheck do
  it 'reports correctly the basic use case' do
    src = <<-EOS
      def nilcheck foo
        foo.nil?
      end
    EOS
    expect(src).to reek_of :NilCheck,
                           name: :nilcheck,
                           lines: [2],
                           message: 'performs a nil-check'
  end

  it 'reports nothing when scope includes no nil checks' do
    expect('def no_nils; end').not_to reek_of(:NilCheck)
  end

  it 'reports when scope uses multiple nil? methods' do
    src = <<-EOS
    def chk_multi_nil(para)
      para.nil?
      puts "Hello"
      \"\".nil?
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports twice when scope uses == nil and === nil' do
    src = <<-EOS
    def chk_eq_nil(para)
      para == nil
      para === nil
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses nil ==' do
    expect('def chk_eq_nil_rev(para); nil == para; end').to reek_of(:NilCheck)
  end

  it 'reports when scope uses multiple case-clauses checking nil' do
    src = <<-EOS
    def case_nil
      case @inst_var
      when nil then puts "Nil"
      end
      puts "Hello"
      case @inst_var2
      when 1 then puts 1
      when nil then puts nil.inspect
      end
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end

  it 'reports a when clause that checks nil and other values' do
    src = <<-EOS
    def case_nil
      case @inst_var
      when nil, false then puts "Hello"
      end
    end
    EOS
    expect(src).to reek_of(:NilCheck)
  end
end
