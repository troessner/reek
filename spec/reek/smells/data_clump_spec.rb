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
    src.should_not smell_of(DataClump)
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
      ctx = CodeContext.new(nil, @src.to_reek_source.syntax_tree)
      detector = DataClump.new('newt')
      @smells = detector.examine_context(ctx)
      @warning = @smells[0]   # SMELL: too cumbersome!
      @yaml = @warning.to_yaml
    end
    it 'records only the one smell' do
      @smells.length.should == 1
    end
    it 'reports all parameters' do
      @smells[0].smell[DataClump::PARAMETERS_KEY].should == ['pa', 'pb']
    end
    it 'reports the number of occurrences' do
      @smells[0].smell[DataClump::OCCURRENCES_KEY].should == 3
    end
    it 'reports all methods' do
      @smells[0].smell[DataClump::METHODS_KEY].should == ['first', 'second', 'third']
    end
    it 'reports the declaration line numbers' do
      @smells[0].lines.should == [2,3,4]
    end
    it 'reports the correct smell class' do
      @smells[0].smell_class.should == DataClump::SMELL_CLASS
    end
    it 'reports the context fq name' do
      @smells[0].context.should == @module_name
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
    src.should smell_of(DataClump, {DataClump::OCCURRENCES_KEY => 3,
      DataClump::PARAMETERS_KEY => ['pa', 'pb']})
  end

  it 'reports 3 identical parameter sets' do
    src = <<EOS
#{@context} Scrunch
  def first(pa, pb, pc) @field == :sym ? 0 : 3; end
  def second(pa, pb, pc) @field == :sym; end
  def third(pa, pb, pc) pa - pb + @fred; end
end
EOS
    src.should smell_of(DataClump, {DataClump::OCCURRENCES_KEY => 3,
      DataClump::PARAMETERS_KEY => ['pa', 'pb', 'pc']})
  end

  it 'reports re-ordered identical parameter sets' do
    src = <<EOS
#{@context} Scrunch
  def first(pb, pa, pc) @field == :sym ? 0 : 3; end
  def second(pc, pb, pa) @field == :sym; end
  def third(pa, pb, pc) pa - pb + @fred; end
end
EOS
    src.should smell_of(DataClump, {DataClump::OCCURRENCES_KEY => 3,
      DataClump::PARAMETERS_KEY => ['pa', 'pb', 'pc']})
  end

  it 'counts only identical parameter sets' do
    src = <<EOS
#{@context} RedCloth
  def fa(p1, p2, p3, conten) end
  def fb(p1, p2, p3, conten) end
  def fc(name, windowW, windowH) end
end
EOS
    src.should_not smell_of(DataClump)
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
    src.should smell_of(DataClump, DataClump::OCCURRENCES_KEY => 5)
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
    src.should_not smell_of(DataClump)
  end

  it 'detects clumps smaller than the total number of arguments' do
    src = <<-EOS
      #{@context} Smelly
        def fa(p1, p2, p3) end
        def fb(p1, p3, p2) end
        def fc(p4, p1, p2) end
      end
    EOS
    src.should smell_of(DataClump,
                        { DataClump::PARAMETERS_KEY => %w(p1 p2) })
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
