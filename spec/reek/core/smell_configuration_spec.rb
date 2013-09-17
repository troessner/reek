require 'spec_helper'
require 'reek/core/smell_configuration'

include Reek::Core

describe SmellConfiguration do
  it 'returns the default value when key not found' do
    cf = SmellConfiguration.new({})
    cf.value('fred', nil, 27).should == 27
  end

  context 'when overriding default configs' do
    before(:each) do
      @base_config = {"enabled"=>true, "exclude"=>[],
                      "reject"=>[/^.$/, /[0-9]$/, /[A-Z]/],
                      "accept"=>["_"]}
      @smell_config = SmellConfiguration.new(@base_config)
    end

    it { @smell_config.merge!({}).should == @base_config }
    it { @smell_config.merge!({"enabled"=>true}).should == @base_config }
    it { @smell_config.merge!({"exclude"=>[]}).should == @base_config }
    it { @smell_config.merge!({"accept"=>["_"]}).should == @base_config }
    it { @smell_config.merge!({"reject"=>[/^.$/, /[0-9]$/, /[A-Z]/]}).should == @base_config }
    it { @smell_config.merge!({"enabled"=>true, "accept"=>["_"]}).should == @base_config }

    it 'should override single values' do
      @smell_config.merge!({"enabled"=>false}).should == {"enabled"=>false, "exclude"=>[],
                                                          "reject"=>[/^.$/, /[0-9]$/, /[A-Z]/],
                                                          "accept"=>["_"]}
    end

    it 'should override arrays of values' do
      @smell_config.merge!({"reject"=>[/^.$/, /[3-9]$/]}).should == {"enabled"=>true,
                                                          "exclude"=>[],
                                                          "reject"=>[/^.$/, /[3-9]$/],
                                                          "accept"=>["_"]}
    end

    it 'should override multiple values' do
      @smell_config.merge!({"enabled"=>false, "accept"=>[/[A-Z]$/]}).should ==
                           {"enabled"=>false, "exclude"=>[],
                            "reject"=>[/^.$/, /[0-9]$/, /[A-Z]/],
                            "accept"=>[/[A-Z]$/]}
    end
  end
end
