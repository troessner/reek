require File.dirname(__FILE__) + '/spec_helper.rb'

require 'flay'

class ShouldDuplicate
  def initialize(threshold)
    @threshold = threshold
    @flay = Flay.new({:fuzzy => false, :verbose => false, :mass => @threshold})
  end
  def matches?(actual)
    @flay.process(*Flay.expand_dirs_to_files(actual))
    @flay.total > 0
  end
  def failure_message_for_should
    "Expected source to contain duplication, but it didn't"
  end
  def failure_message_for_should_not
    "Expected source not to contain duplication, but got:\n#{report}"
  end
  def report
    lines = ["Total mass = #{@flay.total} (threshold = #{@threshold})"]
    @flay.masses.each do |hash, mass|
      nodes = @flay.hashes[hash]
      match = @flay.identical[hash] ? "IDENTICAL" : "Similar"
      lines << ("%s code found in %p" % [match, nodes.first.first])
      nodes.each { |x| lines << "  #{x.file}:#{x.line}" }
    end
    lines.join("\n")
  end
end

def duplicate(threshold)
  ShouldDuplicate.new(threshold)
end

describe 'Reek source code' do
  it 'has no smells' do
    Dir['lib/**/*.rb'].should_not reek
  end

  # SMELL -- should be part of Reek
  nucleus = Dir['lib/reek/**/*.rb'] - Dir['lib/reek/adapters/**/*.rb']
  nucleus.each do |src|
    it "#{src} contains no references from the nucleus out to the adapters" do
      IO.readlines(src).grep(/adapters/).should == []
    end
  end

  it 'has no duplication' do
    ['lib', 'spec/reek'].should_not duplicate(40)
  end
end
