require 'spec_helper'
require 'reek/source/reference_collector'

include Reek::Source

describe ReferenceCollector do
  context 'counting refs to self' do
    def refs_to_self(src)
      ReferenceCollector.new(src.to_reek_source.syntax_tree).num_refs_to_self
    end
    it 'with no refs to self' do
      expect(refs_to_self('def no_envy(arga) arga.barg end')).to eq(0)
    end
    it 'counts a call to super' do
      expect(refs_to_self('def simple() super; end')).to eq(1)
    end
    it 'counts a local call' do
      expect(refs_to_self('def simple() to_s; end')).to eq(1)
    end
    it 'counts a use of self' do
      expect(refs_to_self('def simple() lv = self; end')).to eq(1)
    end
    it 'counts a call with self as receiver' do
      expect(refs_to_self('def simple() self.to_s; end')).to eq(1)
    end
    it 'counts uses of an ivar' do
      expect(refs_to_self('def no_envy() @item.to_a; @item = 4; @item end')).to eq(3)
    end
    it 'counts an ivar passed to a method' do
      expect(refs_to_self('def no_envy(arga) arga.barg(@item); arga end')).to eq(1)
    end
    it 'ignores global variables' do
      expect(refs_to_self('def no_envy(arga) $s2.to_a; $s2[arga] end')).to eq(0)
    end
    it 'ignores global variables' do
      src = <<EOS
    def accept(t, pat = /.*/nm, &block)
      if pat
        pat.respond_to?(:match) or raise TypeError, "has no `match'"
      else
        pat = t if t.respond_to?(:match)
      end
      unless block
        block = pat.method(:convert).to_proc if pat.respond_to?(:convert)
      end
      @atype[t] = [pat, block]
    end
EOS
      expect(refs_to_self(src)).to eq(2)
    end
  end
end
