require File.dirname(__FILE__) + '/spec_helper.rb'

require 'flay'

Spec::Matchers.define :flay do |threshold|
  match do |dirs_and_files|
    @threshold = threshold
    @flay = Flay.new({:fuzzy => false, :verbose => false, :mass => @threshold})
    @flay.process(*Flay.expand_dirs_to_files(dirs_and_files))
    @flay.total > 0
  end
  
  failure_message_for_should do
    "Expected source to contain duplication, but it didn't"
  end
  
  failure_message_for_should_not do
    "Expected source not to contain duplication, but got:\n#{report}"
  end
  
  def report
    lines = ["Total mass = #{@flay.total} (threshold = #{@threshold})"]
    @flay.masses.each do |hash, mass|
      nodes = @flay.hashes[hash]
      match = @flay.identical[hash] ? "IDENTICAL" : "Similar"
      lines << ("%s code found in %p (%d)" % [match, nodes.first.first, mass])
      nodes.each { |x| lines << "  #{x.file}:#{x.line}" }
    end
    lines.join("\n")
  end
end

Spec::Matchers.define :simian do |threshold|
  match do |dirs_and_files|
    files = Flay.expand_dirs_to_files(dirs_and_files).join(' ')
    simian_jar = Dir["#{ENV['SIMIAN_HOME']}/simian*.jar"].first
    @simian = `java -jar #{simian_jar} -threshold=#{threshold} #{files}`
    !@simian.include?("Found 0 duplicate lines")
  end
  
  failure_message_for_should do
    "Expected source to contain textual duplication, but it didn't"
  end
  
  failure_message_for_should_not do
    "Expected source not to contain textual duplication, but got:\n#{@simian}"
  end
end

describe 'Reek source code' do
  it 'has no smells' do
    Dir['lib/**/*.rb'].should_not reek
  end
  it 'has no structural duplication' do
    ['lib'].should_not flay(16)
  end
  it 'has no textual duplication' do
    ['lib'].should_not simian(3)
  end
  it 'has no structural duplication in the tests' do
    ['spec/reek'].should_not flay(25)
  end
  it 'has no textual duplication in the tests' do
    ['spec/reek'].should_not simian(8)
  end
end
