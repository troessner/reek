require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'spec/reek/code_checks'
require 'reek/smells/control_couple'

include CodeChecks
include Reek::Smells

describe ControlCouple do
  check 'should report a ternary check on a parameter',
    'def simple(arga) arga ? @ivar : 3 end', [[/arga/]]
  check 'should not report a ternary check on an ivar',
    'def simple(arga) @ivar ? arga : 3 end', []
  check 'should not report a ternary check on a lvar',
    'def simple(arga) lvar = 27; lvar ? arga : @ivar end', []
  check 'should spot a couple inside a block',
    'def blocks(arg) @text.map { |blk| arg ? blk : "#{blk}" } end', [[/arg/]]
end
