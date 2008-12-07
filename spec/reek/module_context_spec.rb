require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'spec/reek/code_checks'
require 'reek/module_context'

include CodeChecks
include Reek

describe ModuleContext do
  check 'should report module name for smell in method',
    'module Fred; def simple(x) true; end; end', [[/x/, /simple/, /Fred/]]
end
