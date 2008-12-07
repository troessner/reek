require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'spec/reek/code_checks'

include CodeChecks

require 'reek/code_parser'
require 'reek/report'

include Reek

describe CodeParser, "(Long Method)" do
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
  check 'should report long inner block', src, [[/8 statements/]]
end
