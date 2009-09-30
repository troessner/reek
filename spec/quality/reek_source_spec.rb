require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Reek source code' do
  it 'has no smells' do
    Dir['lib/**/*.rb'].should_not reek
  end

  nucleus = Dir['lib/reek/**.rb'] - Dir['lib/reek/adapters/**/*.rb']
  nucleus.each do |src|
    it "#{src} contains no references from the nucleus out to the adapters" do
      IO.readlines(src).grep(/adapters/).should == []
    end
  end

end
