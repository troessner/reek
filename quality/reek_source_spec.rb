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

class ShouldSimian
  def initialize(threshold)
    @threshold = threshold
  end
  def matches?(actual)
    files = Flay.expand_dirs_to_files(actual).join(' ')
    simian_jar = Dir["#{ENV['SIMIAN_HOME']}/simian*.jar"].first
    @simian = `java -jar #{simian_jar} -threshold=#{@threshold} #{files}`
    !@simian.include?("Found 0 duplicate lines")
  end
  def failure_message_for_should
    "Expected source to contain textual duplication, but it didn't"
  end
  def failure_message_for_should_not
    "Expected source not to contain textual duplication, but got:\n#{@simian}"
  end
end

def flay(threshold)
  ShouldDuplicate.new(threshold)
end

def simian(threshold)
  ShouldSimian.new(threshold)
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

  it 'has no structural duplication' do
    ['lib', 'spec/reek'].should_not flay(40)
  end
  it 'has no textual duplication' do
    ['lib'].should_not simian(2)
  end
  it 'has no textual duplication in the tests' do
    ['spec/reek'].should_not simian(8)
  end
end
