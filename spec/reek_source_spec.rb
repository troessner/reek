require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'Reek source code:' do
  Dir['lib/**/*.rb'].each do |source|
    describe source do
      it 'should report no smells' do
        `ruby -Ilib bin/reek #{source}`.should == "\n"
      end
    end
  end
end
