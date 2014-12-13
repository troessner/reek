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
      expect(smells[0].lines).to eq [2]
    end

    it 'reports nothing when scope includes no nil checks' do
      expect('def no_nils; end').not_to smell_of(NilCheck)
    end

    it 'reports when scope uses multiple nil? methods' do
      src = <<-eos
      def chk_multi_nil(para)
        para.nil?
        puts "Hello"
        \"\".nil?
      end
      eos
      expect(src).to smell_of(NilCheck, {}, {})
    end

    it 'reports twice when scope uses == nil and === nil' do
      src = <<-eos
      def chk_eq_nil(para)
        para == nil
        para === nil
      end
      eos
      expect(src).to smell_of(NilCheck, {}, {})
    end

    it 'reports when scope uses nil ==' do
      expect('def chk_eq_nil_rev(para); nil == para; end').to smell_of(NilCheck)
    end

    it 'reports when scope uses multiple case-clauses checking nil' do
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
      expect(src).to smell_of(NilCheck, {}, {})
    end

    it 'reports a when clause that checks nil and other values' do
      src = <<-eos
      def case_nil
        case @inst_var
        when nil, false then puts "Hello"
        end
      end
      eos
      expect(src).to smell_of(NilCheck)
    end
  end
end
