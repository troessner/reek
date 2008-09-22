require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, "(Long Method)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report short methods' do
    @cchk.check_source('def short(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;end')
    @rpt.should be_empty
  end

  it 'should report long methods' do
    @cchk.check_source('def long(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end')
    @rpt.length.should == 1
    @rpt[0].should be_instance_of(LongMethod)
  end

  it 'should only report a long method once' do
    source =<<EOS
  def standard_entries(rbconfig)
    @abc = rbconfig
    rubypath = File.join(@abc['bindir'], @abcf['ruby_install_name'] + cff['EXEEXT'])
    major = yyy['MAJOR'].to_i
    minor = zzz['MINOR'].to_i
    teeny = ccc['TEENY'].to_i
    version = ""
    if c['rubylibdir']
      @libruby         = "/lib/ruby"
      @librubyver      = "/lib/ruby/"
      @librubyverarch  = "/lib/ruby/"
      @siteruby        = "lib/ruby/version/site_ruby"
      @siterubyver     = siteruby
      @siterubyverarch = "$siterubyver/['arch']}"
    end
  end
EOS
    @cchk.check_source(source)
    @rpt.length.should == 1
    @rpt[0].should be_instance_of(LongMethod)
  end
end

describe MethodChecker, "(Long Block)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should report long inner block' do
    src = <<EOS
def long(arga)
  f(3)
  self.each do |xyzero|
    xyzero = 1
    xyzero = 2
    xyzero = 3
    xyzero = 4
    xyzero = 5
    xyzero = 6
  end
end
EOS
    @cchk.check_source(src)
    @rpt.length.should == 1
  end
end
