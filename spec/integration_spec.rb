require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'Integration test:' do
  Dir['spec/samples/*.rb'].each do |source|
    describe source do
      before :each do
        @expected = IO.readlines(source.sub(/\.rb/, '.reek'))
        @expected.each {|line| line.chomp!}
      end

      it 'should report the correct smells' do
        actual = `ruby -Ilib bin/reek #{source} 2>/dev/null`.split(/\n/)
        @expected.zip(actual).each do |p|
          actual = p[1] ? p[1].chomp : p[1]
          actual.should == p[0]
        end
      end

      it 'should report the correct smells in smell order' do
        actual = `ruby -Ilib bin/reek --sort smell #{source} 2>/dev/null`.split(/\n/)
        @expected.sort.zip(actual).each do |p|
          actual = p[1] ? p[1].chomp : p[1]
          actual.should == p[0]
        end
      end
    end
  end
end

describe 'Reek source code:' do
  Dir['lib/**/*.rb'].each do |source|
    describe source do
      it 'should report no smells' do
        `ruby -Ilib bin/reek #{source}`.should == "\n"
      end
    end
  end
end
