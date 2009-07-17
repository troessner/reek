require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Reek source code:' do
  Dir['lib/**/*.rb'].each do |path|
    it "reports no smells in #{path}" do
      File.new(path).should_not reek
    end
  end

  it 'reports no smells via the Dir matcher' do
    Dir['lib/**/*.rb'].should_not reek
  end
end
