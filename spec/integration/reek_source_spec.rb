require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Reek source code:' do
  Dir['lib/**/*.rb'].each do |source|
    describe source do
      it 'should report no smells' do
        `ruby -Ilib bin/reek #{source}`.should == ''
        $?.exitstatus.should == 0
      end
    end
  end

  it 'should report no duplication' do
    files = Dir['lib/**/*.rb'].join(' ')
    report = `flay #{files} 2>/dev/null`
    report.should == ''
  end
end

#describe 'Reek tests:' do
#  it 'should report no duplication' do
#    files = Dir['spec/**/*_spec.rb'].join(' ')
#    report = `flay #{files} 2>/dev/null`
#    report.should == ''
#  end
#end
