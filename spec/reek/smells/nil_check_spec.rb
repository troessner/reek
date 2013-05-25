require 'spec_helper'
require 'reek/smells/nil_check'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe NilCheck do

  context 'for methods' do

    it 'reports the correct line number' do
      src = <<-EOS
      def nilcheck foo
        foo.nil?
      end
      EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      detector = NilCheck.new('source_name')
      smells = detector.examine_context(ctx)
      smells[0].lines.should eq [2]
    end

    it 'should report nothing when scope includes no nil checks' do
      'def no_nils; end'.should_not smell_of(NilCheck)
    end

    it 'should report when scope uses multiple nil? methods' do
      src = <<-eos
      def chk_multi_nil(para)
        para.nil?
        puts "Hello"
        \"\".nil?
      end
      eos
      src.should smell_of(NilCheck,
                          {NilCheck => nil}, {NilCheck => nil})
    end

    it 'should report twice when scope uses == nil and === nil' do
      src= <<-eos
      def chk_eq_nil(para)
        para == nil
        para === nil
      end
      eos
      src.should smell_of(NilCheck,
                          {NilCheck => nil}, {NilCheck => nil})
    end

    it 'should report when scope uses nil ==' do
      'def chk_eq_nil_rev(para); nil == para; end'.should smell_of(NilCheck)
    end

    it 'should report when scope uses multiple case-clauses checking nil' do
      src = <<-eos
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
      eos
      src.should smell_of(NilCheck,
                          {NilCheck => nil}, {NilCheck => nil})
    end
  end
end
