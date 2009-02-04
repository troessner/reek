require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/version'

describe 'version number' do
  it 'should report the correct value' do
    actual = `ruby -Ilib bin/reek --version`.split
    $?.exitstatus.should == 0
    actual[0].should == 'reek'
    actual[1].should == Reek::VERSION::STRING
  end
end

describe 'exit status', 'when reek is used incorrectly' do
  it 'should return non-zero status on bad option' do
    `ruby -Ilib bin/reek --no-such-option`
    $?.exitstatus.should == 1
  end

  it 'should not complain about missing file' do
    `ruby -Ilib bin/reek nosuchfile.rb 2>/dev/null`
    $?.exitstatus.should == 0
  end

  it 'should return non-zero status on missing argument' do
    `ruby -Ilib bin/reek -f 2>/dev/null`
    $?.exitstatus.should == 1
  end

  it 'should not complain when no source given' do
    `ruby -Ilib bin/reek 2>/dev/null`
    $?.exitstatus.should == 0
  end
end

describe 'exit status', 'when reek is used correctly' do
  it 'should return non-zero status when smells are reported' do
    `ruby -Ilib bin/reek "def x() 3; end"`
    $?.exitstatus.should == 2
  end

  it 'should return zero status with no smells' do
    `ruby -Ilib bin/reek "def simple() @fred = 3 end"`
    $?.exitstatus.should == 0
  end
end

describe 'report format', 'with no sources' do
  it 'should output nothing' do
    `ruby -Ilib bin/reek`.should be_empty
  end
end

describe 'report format', 'with one source' do
  it 'should output nothing with empty source' do
    `ruby -Ilib bin/reek ""`.should be_empty
  end

  it 'should output nothing when no smells' do
    `ruby -Ilib bin/reek "def simple() @fred = 3; end"`.should be_empty
  end

  it 'should not adorn the list of warnings' do
    report = `ruby -Ilib bin/reek "class Turn; def y() @x = 3; end end"`
    report.split(/\n/).length.should == 2
    report.should_not match(/\n\n/)
  end
end
