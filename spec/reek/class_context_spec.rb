require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'spec/reek/code_checks'
require 'reek/class_context'

include CodeChecks
include Reek

describe ClassContext do
  check 'should report Long Parameter List',
    'class Inner; def simple(arga, argb, argc, argd) f(3);true end end', [[/Inner/, /simple/, /4 parameters/]]

    src = <<EOEX
class Fred
  def simple(arga, argb, argc, argd) f(3);true end
  def simply(arga, argb, argc, argd) f(3);false end
end
EOEX
  check 'should report two different methods', src, [[/Fred/, /simple/], [/Fred/, /simply/]]

    src = <<EOEX
class Fred
    def textile_bq(tag, atts, cite, content) f(3);end
    def textile_p(tag, atts, cite, content) f(3);end
    def textile_fn_(tag, num, atts, cite, content) f(3);end
    def textile_popup_help(name, windowW, windowH) f(3);end
end
EOEX
  check 'should report many different methods', src,
    [[/Fred/, /textile_bq/], [/Fred/, /textile_fn_/], [/Fred/, /textile_p/]]
end
