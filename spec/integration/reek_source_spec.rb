require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Reek source code:' do
  Dir['lib/**/*.rb'].each do |path|
    it "reports no smells in #{path}" do
      File.new(path).should_not reek
    end
    it "reports no smells in #{path} via bin/reek" do
      `ruby -Ilib bin/reek #{path}`.should == ''
      $?.exitstatus.should == 0
    end
  end
end

describe 'RakeTask' do
  it 'should report no duplication' do
    report = `rake reek`.split("\n")
    report.length.should == 1
  end
end
