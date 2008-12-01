require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

def check(desc, src, expected, pending_str = nil)
  it(desc) do
    pending(pending_str) unless pending_str.nil?
    rpt = Report.new
    cchk = MethodChecker.new(rpt)
    cchk.check_source(src)
    rpt.length.should == expected.length
    (0...rpt.length).each do |smell|
      expected[smell].each { |patt| rpt[smell].detailed_report.should match(patt) }
    end
  end
end

describe MethodChecker, "(Long Method)" do
  check 'should not report short methods',
    'def short(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;end', []
  check 'should report long methods',
    'def long(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end', [[/6 statements/]]
  check 'should not report initialize',
    'def initialize(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end', []

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
  check 'should only report a long method once', source, [[]]
end

describe MethodChecker, "(Long Block)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt)
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
