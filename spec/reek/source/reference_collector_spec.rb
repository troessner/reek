require 'spec_helper'
require 'reek/source/reference_collector'

include Reek::Source

describe ReferenceCollector do

  context 'counting refs to self' do
    def refs_to_self(src)
      ReferenceCollector.new(src.to_reek_source.syntax_tree).num_refs_to_self
    end
    it 'with no refs to self' do
      refs_to_self('def no_envy(arga) arga.barg end').should == 0
    end
    it 'counts a call to super' do
      refs_to_self('def simple() super; end').should == 1
    end
    it 'counts a local call' do
      refs_to_self('def simple() to_s; end').should == 1
    end
    it 'counts a use of self' do
      refs_to_self('def simple() lv = self; end').should == 1
    end
    it 'counts a call with self as receiver' do
      refs_to_self('def simple() self.to_s; end').should == 1
    end
    it 'counts uses of an ivar' do
      refs_to_self('def no_envy() @item.to_a; @item = 4; @item end').should == 3
    end
    it 'counts an ivar passed to a method' do
      refs_to_self('def no_envy(arga) arga.barg(@item); arga end').should == 1
    end
    it 'ignores global variables' do
      refs_to_self('def no_envy(arga) $s2.to_a; $s2[arga] end').should == 0
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
      refs_to_self(src).should == 2
    end
  end
end
