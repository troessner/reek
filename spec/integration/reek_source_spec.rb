require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Reek source code:' do
  Dir['lib/**/*.rb'].each do |source|
    describe source do
      it 'should report no smells' do
        File.new(source).should_not reek
      end
      it 'should report no smells via bin/reek' do
        `ruby -Ilib bin/reek #{source}`.should == ''
        $?.exitstatus.should == 0
      end
    end
  end
end

describe 'RakeTask' do
  it 'should report no duplication' do
    report = `rake reek`.split("\n")
    report.length.should == 1
  end
end
