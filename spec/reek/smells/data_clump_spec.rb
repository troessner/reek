require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/data_clump'

include Reek::Smells

describe DataClump do
  it 'should not report small parameter sets' do
    src = <<EOS
class Scrunch
  def first(pa) @field == :sym ? 0 : 3; end
  def second(pa) @field == :sym; end
  def third(pa) pa - pb + @fred; end
end
EOS

    src.should_not reek
  end

  it 'should report 3 identical pairs in a class' do
    src = <<EOS
class Scrunch
  def first(pa, pb) @field == :sym ? 0 : 3; end
  def second(pa, pb) @field == :sym; end
  def third(pa, pb) pa - pb + @fred; end
end
EOS

    src.should reek_of(:DataClump, /\[pa, pb\]/, /3 methods/)
  end

  it 'should report 3 swapped pairs in a class' do
    src = <<EOS
class Scrunch
  def one(pa, pb) @field == :sym ? 0 : 3; end
  def two(pb, pa) @field == :sym; end
  def tri(pa, pb) pa - pb + @fred; end
end
EOS

    src.should reek_of(:DataClump, /\[pa, pb\]/, /3 methods/)
  end

  it 'should report 3 identical parameter sets in a class' do
    src = <<EOS
class Scrunch
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

  it 'should recognise re-ordered identical parameter sets' do
    src = <<EOS
class Scrunch
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

  it 'should count only identical parameter sets' do
    src = <<EOS
class RedCloth
  def fa(p1, p2, p3, conten) end
  def fb(p1, p2, p3, conten) end
  def fc(name, windowW, windowH) end
end
EOS

    src.should_not reek_of(:DataClump)
  end

  # TODO: include singleton methods in the calcs
end
