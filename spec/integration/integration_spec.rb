require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Integration test:' do
  Dir['spec/samples/*.rb'].each do |source|
    describe source do
      before :each do
        @expected = IO.readlines("#{source}.expected")
        @expected.each {|line| line.chomp!}
      end

      it 'should report the correct smells in smell order' do
        actual = `ruby -Ilib -- bin/reek -c #{source} 2>/dev/null`.split(/\n/)
        actual.length.should == @expected.length
        @expected.zip(actual).each do |p|
          actual_line = p[1] ? p[1].chomp : p[1]
          actual_line.should == p[0]
        end
      end
    end
  end
end
