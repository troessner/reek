require 'spec_helper'
require 'reek/smells/data_clump'
require 'reek/smells/smell_detector_shared'

include Reek::Smells

shared_examples_for 'a data clump detector' do
  it 'does not report small parameter sets' do
    src = <<EOS
# test module
#{@context} Scrunch
  def first(pa) @field == :sym ? 0 : 3; end
  def second(pa) @field == :sym; end
  def third(pa) pa - pb + @fred; end
end
EOS
    expect(src).not_to smell_of(DataClump)
  end

  context 'with 3 identical pairs' do
    before :each do
      @module_name = 'Scrunch'
      @src = <<EOS
#{@context} #{@module_name}
  def first(pa, pb) @field == :sym ? 0 : 3; end
  def second(pa, pb) @field == :sym; end
  def third(pa, pb) pa - pb + @fred; end
end
EOS
      ctx = ModuleContext.new(nil, @src.to_reek_source.syntax_tree)
      detector = DataClump.new('newt')
      @smells = detector.examine_context(ctx)
    end
    it 'records only the one smell' do
      expect(@smells.length).to eq(1)
    end
    it 'reports all parameters' do
      expect(@smells[0].parameters[:parameters]).to eq(['pa', 'pb'])
    end
    it 'reports the number of occurrences' do
      expect(@smells[0].parameters[:count]).to eq(3)
    end
    it 'reports all methods' do
      expect(@smells[0].parameters[:methods]).to eq(['first', 'second', 'third'])
    end
    it 'reports the declaration line numbers' do
      expect(@smells[0].lines).to eq([2, 3, 4])
    end
    it 'reports the correct smell class' do
      expect(@smells[0].smell_category).to eq(DataClump.smell_category)
    end
    it 'reports the context fq name' do
      expect(@smells[0].context).to eq(@module_name)
    end
  end

  it 'reports 3 swapped pairs' do
    src = <<EOS
#{@context} Scrunch
  def one(pa, pb) @field == :sym ? 0 : 3; end
  def two(pb, pa) @field == :sym; end
  def tri(pa, pb) pa - pb + @fred; end
end
EOS
    expect(src).to smell_of(DataClump,
                            count: 3,
                            parameters: ['pa', 'pb'])
  end

  it 'reports 3 identical parameter sets' do
    src = <<EOS
#{@context} Scrunch
  def first(pa, pb, pc) @field == :sym ? 0 : 3; end
  def second(pa, pb, pc) @field == :sym; end
  def third(pa, pb, pc) pa - pb + @fred; end
end
EOS
    expect(src).to smell_of(DataClump,
                            count: 3,
                            parameters: ['pa', 'pb', 'pc'])
  end

  it 'reports re-ordered identical parameter sets' do
    src = <<EOS
#{@context} Scrunch
  def first(pb, pa, pc) @field == :sym ? 0 : 3; end
  def second(pc, pb, pa) @field == :sym; end
  def third(pa, pb, pc) pa - pb + @fred; end
end
EOS
    expect(src).to smell_of(DataClump,
                            count: 3,
                            parameters: ['pa', 'pb', 'pc'])
  end

  it 'counts only identical parameter sets' do
    src = <<EOS
#{@context} RedCloth
  def fa(p1, p2, p3, conten) end
  def fb(p1, p2, p3, conten) end
  def fc(name, windowW, windowH) end
end
EOS
    expect(src).not_to smell_of(DataClump)
  end

  it 'gets a real example right' do
    src = <<EOS
#{@context} Inline
  def generate(src, options) end
  def c (src, options) end
  def c_singleton (src, options) end
  def c_raw (src, options) end
  def c_raw_singleton (src, options) end
end
EOS
    expect(src).to smell_of(DataClump, count: 5)
  end

  it 'correctly checks number of occurences' do
    src = <<-EOS
      #{@context} Smelly
        def fa(p1, p2, p3) end
        def fb(p2, p3, p4) end
        def fc(p3, p4, p5) end
        def fd(p4, p5, p1) end
        def fe(p5, p1, p2) end
      end
    EOS
    expect(src).not_to smell_of(DataClump)
  end

  it 'detects clumps smaller than the total number of arguments' do
    src = <<-EOS
      #{@context} Smelly
        def fa(p1, p2, p3) end
        def fb(p1, p3, p2) end
        def fc(p4, p1, p2) end
      end
    EOS
    expect(src).to smell_of(DataClump,
                            parameters: %w(p1 p2))
  end

  it 'ignores anonymous parameters' do
    src = <<-EOS
      #{@context} Smelly
        def fa(p1, p2, *) end
        def fb(p1, p2, *) end
        def fc(p1, p2, *) end
      end
    EOS
    expect(src).to smell_of(DataClump,
                            parameters: %w(p1 p2))
  end
end

describe DataClump do
  before(:each) do
    @detector = DataClump.new('newt')
  end

  it_should_behave_like 'SmellDetector'

  context 'in a class' do
    before :each do
      @context = 'class'
    end

    it_should_behave_like 'a data clump detector'
  end

  context 'in a module' do
    before :each do
      @context = 'module'
    end

    it_should_behave_like 'a data clump detector'
  end

  # TODO: include singleton methods in the calcs
end
