require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/code_parser'
require 'reek/report'

include Reek

describe LongMethod do
  it 'should not report short methods' do
    'def short(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;end'.should_not reek
  end

  it 'should report long methods' do
    'def long(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end'.should reek_only_of(:LongMethod, /6 statements/)
  end

  it 'should not report initialize' do
    'def initialize(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end'.should_not reek
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
    source.should reek_only_of(:LongMethod)
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
    src.should reek_only_of(:LongMethod)
  end
end
