require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'spec/reek/code_checks'

include CodeChecks

describe CodeParser, " nested iterators" do

  check 'should report nested iterators in a method',
    'def bad(fred) @fred.each {|item| item.each {|ting| ting.ting} } end', [[/bad/, /nested/]]

  check 'should not report method with successive iterators',
    'def bad(fred)
      @fred.each {|item| item.each }
      @jim.each {|ting| ting.each }
    end', []

  check 'should not report method with chained iterators',
    'def chained
      @sig.keys.sort_by { |xray| xray.to_s }.each { |min| md5 << min.to_s }
    end', []

  check 'should report nested iterators only once per method',
    'def bad(fred)
  @fred.each {|item| item.each {|part| @joe.send} }
  @jim.each {|ting| ting.each {|piece| @hal.send} }
end', [[/bad/, /nested/]]
end

