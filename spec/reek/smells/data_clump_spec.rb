require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/data_clump'

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

    src.should_not reek
  end

  context 'with 3 identical pairs' do
    before :each do
      @src = <<EOS
#{@context} Scrunch
  def first(pa, pb) @field == :sym ? 0 : 3; end
  def second(pa, pb) @field == :sym; end
  def third(pa, pb) pa - pb + @fred; end
end
EOS
      ctx = ModuleContext.from_s(@src)
      detector = DataClump.new('newt')
      detector.examine(ctx)
      warning = detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports all parameters' do
      @yaml.should match(/parameters:[\s-]*pa/)
      @yaml.should match(/parameters:[\spa-]*pb/)
    end
    it 'reports the number of occurrences' do
      @yaml.should match(/occurrences:\s*3/)
    end
  end

  it 'reports 3 swapped pairs in a class' do
    src = <<EOS
#{@context} Scrunch
  def one(pa, pb) @field == :sym ? 0 : 3; end
  def two(pb, pa) @field == :sym; end
  def tri(pa, pb) pa - pb + @fred; end
end
EOS

    src.should reek_of(:DataClump, /\[pa, pb\]/, /3 methods/)
  end

  it 'reports 3 identical parameter sets in a class' do
    src = <<EOS
#{@context} Scrunch
  def first(pa, pb, pc) @field == :sym ? 0 : 3; end
  def second(pa, pb, pc) @field == :sym; end
  def third(pa, pb, pc) pa - pb + @fred; end
end
EOS

    src.should reek_of(:DataClump, /\[pa, pb, pc\]/, /3 methods/)
    src.should_not reek_of(:DataClump, /\[pa, pb\]/, /3 methods/)
    src.should_not reek_of(:DataClump, /\[pa, pc\]/, /3 methods/)
    src.should_not reek_of(:DataClump, /\[pb, pc\]/, /3 methods/)
  end

  it 'recognises re-ordered identical parameter sets' do
    src = <<EOS
#{@context} Scrunch
  def first(pb, pa, pc) @field == :sym ? 0 : 3; end
  def second(pc, pb, pa) @field == :sym; end
  def third(pa, pb, pc) pa - pb + @fred; end
end
EOS

    src.should reek_of(:DataClump, /\[pa, pb, pc\]/, /3 methods/)
    src.should_not reek_of(:DataClump, /\[pa, pb\]/, /3 methods/)
    src.should_not reek_of(:DataClump, /\[pa, pc\]/, /3 methods/)
    src.should_not reek_of(:DataClump, /\[pb, pc\]/, /3 methods/)
  end

  it 'counts only identical parameter sets' do
    src = <<EOS
#{@context} RedCloth
  def fa(p1, p2, p3, conten) end
  def fb(p1, p2, p3, conten) end
  def fc(name, windowW, windowH) end
end
EOS

    src.should_not reek_of(:DataClump)
  end
end

describe DataClump do
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

require 'spec/reek/smells/smell_detector_shared'

describe DataClump do
  before(:each) do
    @detector = DataClump.new('newt')
  end

  it_should_behave_like 'SmellDetector'
end
